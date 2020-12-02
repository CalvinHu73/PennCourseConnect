//
//  SignUpViewController.swift
//  PennCourseConnect
//
//  Created by Calvin Hu on 12/1/20.
//  Copyright © 2020 Calvin Hu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var profilePictureView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let profilePictureGesture = UITapGestureRecognizer(target: self, action: #selector(profilePictureTapped))
        profilePictureView.addGestureRecognizer(profilePictureGesture)
        profilePictureView.isUserInteractionEnabled = true
        profilePictureView.layer.borderWidth = 2
        profilePictureView.layer.borderColor = UIColor.lightGray.cgColor
        profilePictureView.layer.cornerRadius = profilePictureView.frame.size.width/2.0
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let email = emailField.text, let password = passwordField.text, !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 8 else {
            let alert = UIAlertController.init(title: "Failed sign up", message: "Please enter all information (password has at least 8 characters)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        //Firebase Sign in
        emailInUse(email: email, completion: { inUse in
            guard !inUse else {
                let alert = UIAlertController.init(title: "Failed sign up", message: "Email already in use", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { result, error in
                guard error == nil, let res = result else {
                    let alert = UIAlertController.init(title: "Failed sign up", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let userData = ["firstName": firstName, "lastName": lastName, "email": email]
                Firestore.firestore().collection("users").document(email).setData(userData)
                
                print("Signed up \(res.user.email ?? res.user.uid)")
                self.performSegue(withIdentifier: "signedUp", sender: nil)
            })
        })
    }
    
    func emailInUse(email: String, completion: @escaping ((Bool) -> Void)) {
        Firestore.firestore().collection("users").whereField("email", isEqualTo: email)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else if querySnapshot!.documents.count > 0 {
                        completion(true)
                }
                completion(false)
        }
    }
    
    @objc func profilePictureTapped() {
        print("prof pic tapped")
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to choose a profile picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction.init(title: "Take a Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction.init(title: "Choose a Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoLibrary()
        }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.allowsEditing = true;
        vc.sourceType = .camera;
        vc.delegate = self
        self.present(vc, animated: true)
    }
    func presentPhotoLibrary() {
        let vc = UIImagePickerController()
        vc.allowsEditing = true;
        vc.sourceType = .photoLibrary;
        vc.delegate = self
        self.present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        profilePictureView.image = editedImage
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
