//
//  ProgressViewController.swift
//  serverfarm
//
//  Created by Washington Family on 2/16/17.
//  Copyright © 2017 Washington. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ServerFarm.initServer() {
            (result: Bool) in
            
            if (result) {
                print("Logged in!")
                self.performSegue(withIdentifier: "ServerFarmView", sender: "")
            }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

}
