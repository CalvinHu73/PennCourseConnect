//
//  CreateSectionViewController.swift
//  PennCourseConnect
//
//  Created by Calvin Hu on 12/1/20.
//  Copyright © 2020 Calvin Hu. All rights reserved.
//

import UIKit

protocol SectionDelegate {
    func createSection(sect : Int)
}

class CreateSectionViewController: UIViewController {

    var delegate : SectionDelegate?
    
    @IBOutlet weak var popup: UIView!
    @IBOutlet weak var textbox: UITextField!
    
    
    @IBAction func submit(_ sender: Any) {
        if let num = Int(textbox.text ?? "") {
            delegate?.createSection(sect: num)
        }
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
