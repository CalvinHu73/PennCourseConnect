//
//  ViewController.swift
//  PennCourseConnect
//
//  Created by Calvin Hu on 11/29/20.
//  Copyright © 2020 Calvin Hu. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

class SignInViewController: UIViewController, GIDSignInDelegate {
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hi")
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 8 else {
            let alert = UIAlertController.init(title: "Failed sign in", message: "Please enter all information (password has at least 8 characters)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        //Firebase Sign in
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { result, error in
            guard error == nil, let res = result else {
                let alert = UIAlertController.init(title: "Failed sign in", message: "Incorrect credentials", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            print("Signed in \(res.user.email ?? res.user.uid)")
            Firestore.firestore().collection("users").document(email).getDocument{ (document, error) in
                if let document = document, document.exists {
                    UserDefaults.standard.set(document.data(), forKey: "userData")
                    self.performSegue(withIdentifier: "signedIn", sender: nil)
                } else {
                    print("Failed to sign in")
                    do {
                        try FirebaseAuth.Auth.auth().signOut()
                    } catch is Any {
                        print("signOut throw")
                    }
                }
            }
        })
    }
    
    
    
    
    
    
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
      // Perform any operations on signed in user here.
        //self.viewDidLoad()
        let vc = storyboard?.instantiateViewController(identifier: "signedIn")
        self.present(vc!, animated: false, completion: nil)
        print("User Eemail: \(user.profile.email ?? "No Email")")
        
        //self.performSegue(withIdentifier: "signedIn", sender: nil)
    }
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    

}

