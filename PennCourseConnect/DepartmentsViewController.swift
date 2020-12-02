//
//  DepartmentsViewController.swift
//  PennCourseConnect
//
//  Created by Calvin Hu on 12/1/20.
//  Copyright © 2020 Calvin Hu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class DepartmentsViewController: UIViewController, CreateDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var department : String?
    var departments = ["abc", "def", "ghi"]
    var docRef : DocumentReference!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FirebaseAuth.Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "notSignedIn", sender: nil)
        }
        
        initializeDepartments()
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
        initializeDepartments()
        // Dismiss the refresh control.
        print("refreshed")
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func clickedCreate(_ sender: Any) {
        performSegue(withIdentifier: "createSegue", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createSegue" {
            let cvc = segue.destination as! CreateViewController
            cvc.delegate = self
        }
        if segue.identifier == "departmentSegue" {
            let vc = segue.destination as! DepartmentViewController
            vc.department = self.department
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = departments[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        department = departments[indexPath.row]
        self.performSegue(withIdentifier: "departmentSegue", sender: nil)
    }
    
    func createDepartment(name: String) {
        if (name != "" && name.count >= 3 && name.count <= 4) {
            departments.append(name)
            let dataToSave : [String: Any] = ["department": name, "valid": true]
            docRef = Firestore.firestore().collection("departments").document(name)
            docRef.setData(dataToSave, completion: { error in
                if let _ = error {
                    print("Error found here!")
                } else {
                    print("No error here!")
                }
            })
            departments = departments.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
            for str in departments {
                print(str)
            }
            tableView.reloadData()
        }
    }
    
    func initializeDepartments() {
        departments.removeAll()
        Firestore.firestore().collection("departments").whereField("valid", isEqualTo: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.departments.append(document.data()["department"] as! String)
                    print(document.data()["department"] as! String)
                }
            }
            DispatchQueue.main.async {
                self.departments = self.departments.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
                print("starting")
                for str in self.departments {
                    print(str)
                }
                print("done")
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
        } catch is Any {
            print("signOut throw")
        }
        if FirebaseAuth.Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "notSignedIn", sender: nil)
        }
    }
}
