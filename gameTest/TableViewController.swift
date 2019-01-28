//
//  TableViewController.swift
//  gameTest
//
//  Created by Nathan Anderson on 10/10/18.
//  Copyright © 2018 Nathan Anderson. All rights reserved.
//

import Foundation
import UIKit

class tableVC : UITableViewController {
    override func viewDidLoad() {
        print("tableVC loaded")
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        print("button")
        self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true, completion: nil)

    }
    
   
    
    
}
