//
//  DepartmentViewController.swift
//  PennCourseConnect
//
//  Created by Calvin Hu on 12/1/20.
//  Copyright © 2020 Calvin Hu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class DepartmentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SectionDelegate {
    
    var sections = [001, 002, 003]
    var docRef : DocumentReference!
    
    var department : String?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = department
        initializeSections()
        configureRefreshControl()
    }
    
    func configureRefreshControl () {
       // Add the refresh control to your UIScrollView object.
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action:
            #selector(handleRefreshControl), for: .valueChanged)
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "hi")
    }
    
    @objc func handleRefreshControl() {
        // Update your content…
        initializeSections()
        // Dismiss the refresh control.
        print("refreshed")
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func clickedCreate(_ sender: Any) {
        performSegue(withIdentifier: "createSectionSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createSectionSegue" {
            let csvc = segue.destination as! CreateSectionViewController
            csvc.delegate = self
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell", for: indexPath)
        let str = String(sections[indexPath.row] + 1000)
        let lower = str.index(after: str.startIndex)
        cell.textLabel?.text = String(str[lower...])
        return cell
    }
    
    func createSection(sect: Int) {
        if (sect > 0 && sect < 999) {
            sections.append(sect)
            let dataToSave : [String: Any] = ["section": sect, "valid": true]
            docRef = Firestore.firestore().collection("departments").document(department!).collection("sections").addDocument(data: dataToSave, completion: { error in
                if let _ = error {
                    print("Error found here!")
                } else {
                    print("No error here!")
                }
            })
            sections = sections.sorted()
            for str in sections {
                print(str)
            }
            tableView.reloadData()
        }
    }
    
    func initializeSections() {
        sections.removeAll()
        Firestore.firestore().collection("departments").document(department!).collection("sections").whereField("valid", isEqualTo: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.sections.append(document.data()["section"] as! Int)
                    print(document.data()["section"] as! Int)
                }
            }
            DispatchQueue.main.async {
                self.sections = self.sections.sorted()
                print("starting")
                for str in self.sections {
                    print(str)
                }
                print("done")
                self.tableView.reloadData()
            }
        }
    }
}
