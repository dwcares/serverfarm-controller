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
    
    var keyboardShowing:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ProgressViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProgressViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        addDoneButtonOnKeyboard()
        doInitServer(serverAddress: loadServerDefault())
        
    }
    
    func loadServerDefault() -> String? {
        let serverAddress: String? = UserDefaults.standard.string(forKey: "serverAddress")
        return serverAddress
    }
    
    func saveServerDefault(serverAddress: String? = nil) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(serverAddress, forKey: "serverAddress")
        userDefaults.synchronize()
    }
    
    func doInitServer(timeout: Double = 15, serverAddress: String? = nil) {
        
        if (serverAddress != nil ) {
            ServerFarm.updateIP(newIp: serverAddress!)
        }

        ServerFarm.initServer(timeout: timeout) {
            (result: Bool) in
            
            if (result) {
                print("Logged in!")

                self.saveServerDefault(serverAddress: ServerFarm.ip)
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
    
    @objc func doneButtonAction() {
        self.serverAddressField.resignFirstResponder()
        
        doInitServer(timeout: 5, serverAddress: self.serverAddressField.text!)
        
    }
    

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if !keyboardShowing {
                keyboardShowing = true
                self.view.frame.origin.y -= keyboardSize.height
                print(keyboardSize.height)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if keyboardShowing {
            keyboardShowing = false
            self.view.frame.origin.y = 0
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
