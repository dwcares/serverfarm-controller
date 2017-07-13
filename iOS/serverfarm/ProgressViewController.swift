//
//  ProgressViewController.swift
//  serverfarm
//
//  Created by Washington Family on 2/16/17.
//  Copyright © 2017 Washington. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {
    
    
    @IBOutlet weak var connectIndicator: UIActivityIndicatorView!
    @IBOutlet weak var serverAddressField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ProgressViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProgressViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        addDoneButtonOnKeyboard()
        doInitServer()
        
    }
    
    func doInitServer(serverAddress: String? = nil) {
        
        if (serverAddress != nil ) {
            ServerFarm.ip = serverAddress!
        }

        ServerFarm.initServer() {
            (result: Bool) in
            
            if (result) {
                print("Logged in!")
                self.performSegue(withIdentifier: "ServerFarmView", sender: "")
            } else {
                print("connection failed")
                
                
                self.serverAddressField.text = ServerFarm.ip
                
                self.connectIndicator.isHidden = true
                self.serverAddressField.isHidden = false
            }
        }

    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ProgressViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.serverAddressField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.serverAddressField.resignFirstResponder()
        
        doInitServer(serverAddress: self.serverAddressField.text!)
        
    }
    

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

}
