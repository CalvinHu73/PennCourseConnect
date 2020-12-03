//
//  ChatViewController.swift
//  PennCourseConnect
//
//  Created by Calvin Hu on 12/2/20.
//  Copyright © 2020 Calvin Hu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController, MessagesDisplayDelegate, MessagesLayoutDelegate, MessagesDataSource, InputBarAccessoryViewDelegate {
    
    var docRef : DocumentReference!
    var messages = [Message]()
    var selfSender = Sender(photoURL: "", senderId: "1", displayName: "user not found")
    
    let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .long
        f.locale = .current
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userData = UserDefaults.standard.value(forKey: "userData") as? [String : Any], let name = userData["firstName"] as? String, let email = userData["email"] as? String {
            selfSender = Sender(photoURL: "", senderId: email, displayName: name)
        } else {
            print("ud failed")
        }
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        //self.initializeMessages()
        self.listenForNewMessage()
        
    }
    
    
    func currentSender() -> SenderType {
       return selfSender
    }
       
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        print("mID: \(messages[indexPath.section].messageId)")
        return messages[indexPath.section]
    }
   
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        print("numSect: \(messages.count)")
        return messages.count
    }
 
    func initializeMessages() {
        messages.removeAll()
        docRef.collection("messages").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    guard let data = document.data() as [String: Any]? else {
                        return
                    }
                    guard let photoURL = data["photoURL"] as? String, let senderId = data["senderId"] as? String, let displayName = data["displayName"] as? String, let messageId = data["messageID"] as? String, let date = self.dateFormatter.date(from: (data["sentDate"] as? String)!), let messageText = data["messageText"] as? String else {
                        return
                    }
                    let sender = Sender(photoURL: photoURL, senderId: senderId, displayName: displayName)
                    guard let type = data["kind"] as? String, type == "text" else {
                        return
                    }
                    let kind = MessageKind.text(messageText)
                    let message = Message(sender: sender, messageId: messageId, sentDate: date, kind: kind)
                    self.messages.append(message)
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                }
            }
        }
    }
    
    func createMessageID(date : Date) -> String {
        let dateString = self.dateFormatter.string(from: date)
        guard let userData = UserDefaults.standard.value(forKey: "userData") as? [String : Any], let email = userData["email"] as? String else {
            return dateString
        }
        let messageID = "\(email)_\(dateString)"
        return messageID
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        inputBar.inputTextView.text = ""
        let date = Date()
        let photoURL: String = selfSender.photoURL
        let senderId: String = selfSender.senderId
        let displayName: String = selfSender.displayName
        let messageId: String = createMessageID(date: date)
        let sentDate: String = self.dateFormatter.string(from: date)
        let kind = "text"
        let dataToSave = ["displayName": displayName, "kind": kind, "messageID": messageId, "messageText": text, "photoURL": photoURL, "senderId": senderId, "sentDate": sentDate]
        docRef.collection("messages").document(messageId).setData(dataToSave)
    }
    
    func listenForNewMessage() {
        docRef.collection("messages").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    guard let data = diff.document.data() as [String: Any]? else {
                        return
                    }
                    guard let photoURL = data["photoURL"] as? String, let senderId = data["senderId"] as? String, let displayName = data["displayName"] as? String, let messageId = data["messageID"] as? String, let date = self.dateFormatter.date(from: (data["sentDate"] as? String)!), let messageText = data["messageText"] as? String else {
                        return
                    }
                    let sender = Sender(photoURL: photoURL, senderId: senderId, displayName: displayName)
                    guard let type = data["kind"] as? String, type == "text" else {
                        return
                    }
                    let kind = MessageKind.text(messageText)
                    let message = Message(sender: sender, messageId: messageId, sentDate: date, kind: kind)
                    self.messages.append(message)
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                }
            }
        }
    }
}
