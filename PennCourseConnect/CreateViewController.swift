//
//  CreateViewController.swift
//  PennCourseConnect
//
//  Created by Calvin Hu on 12/1/20.
//  Copyright © 2020 Calvin Hu. All rights reserved.
//

import UIKit

protocol CreateDelegate {
    func createDepartment(name : String)
}
class CreateViewController: UIViewController {

    var delegate : CreateDelegate?
    
    @IBOutlet weak var popup: UIView!
    @IBOutlet weak var textBox: UITextField!
    
    @IBAction func submit(_ sender: Any) {
        delegate?.createDepartment(name: textBox.text ?? "")
       dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelCreate(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popup.layer.cornerRadius = 10
        popup.layer.masksToBounds = true
    }
}
