//
//  ProfileViewController.swift
//  PennCourseConnect
//
//  Created by Calvin Hu on 12/2/20.
//  Copyright © 2020 Calvin Hu. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
        } catch is Any {
            print("signOut throw")
        }
        if FirebaseAuth.Auth.auth().currentUser == nil {
            UserDefaults.standard.removeObject(forKey: "email")
            self.performSegue(withIdentifier: "signedOut", sender: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
