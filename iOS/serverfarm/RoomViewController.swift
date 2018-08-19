//
//  RoomViewController.swift
//  serverfarm
//
//  Created by Washington Family on 2/9/17.
//  Copyright © 2017 Washington. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import KWStepper

class RoomViewController: UIViewController {
    
    //MARK: Properties
    
    var pageZone: Int!
    
    @IBOutlet weak var buttonPower: UIButton!
    @IBOutlet weak var switchMute: UISwitch!
    @IBOutlet var labelMute: UILabel!
    @IBOutlet weak var segmentSource: UISegmentedControl!
    var page: String!
    
    var stepper: KWStepper!
    @IBOutlet var stepperView: UIView!
    @IBOutlet weak var stepperLabel: UILabel!
    @IBOutlet weak var stepperDown: UIButton!
    @IBOutlet weak var stepperUp: UIButton!

    @IBAction func refreshAction(sender: UIButton) {
        self.updatePageStatusUI()
    }
    
    @IBAction func togglePowerAction(_ sender: UIButton) {
        print("Toggle power")
        togglePowerIndicator()
        ServerFarm.doCommand(zone: pageZone, sourceCmd: ServerFarm.format.sourceCmd.power, globalCmd: nil)  {
            (success: Bool) in
            if (success) {
                self.updatePageStatusUI()
            }
        }
    }
    
    @IBAction func muteChanged(_ sender: UISwitch) {
        ServerFarm.doCommand(zone: pageZone, sourceCmd: ServerFarm.format.sourceCmd.mute, globalCmd: nil)  {
            (success: Bool) in
            if (success) {
                self.updatePageStatusUI()
            }
        }
    }
   
    @IBAction func indexChanged(_ sender : UISegmentedControl) {

        var command = ""
        switch sender.selectedSegmentIndex {
        case 0:
            command = ServerFarm.format.sourceCmd.tuner1
        case 1:
            command = ServerFarm.format.sourceCmd.sonos
        case 2:
            command = ServerFarm.format.sourceCmd.tv
        default:
            break;
        }  //Switch

        ServerFarm.doCommand(zone: pageZone, sourceCmd: command, globalCmd: nil)  {
            (success: Bool) in
            if (success) {
                ServerFarm.setTimeout(0.5, block: { () -> Void in
                        self.updatePageStatusUI()
                })
            }
        }
    }
    
    /////////////

    override func viewDidLoad() {
        super.viewDidLoad()

        // Make the power button round
        buttonPower.layer.cornerRadius = 0.5 * buttonPower.bounds.size.width
        buttonPower.clipsToBounds = true
        
        self.stepperView.layer.opacity = 0
        self.switchMute.layer.opacity = 0
        self.labelMute.layer.opacity = 0
        
        initStepper()
        
        pageZone = getCurrentPageZone()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initStepper() {
        
        // Make the stepper buttons round
        stepperDown.layer.cornerRadius = 0.5 * stepperDown.bounds.size.width
        stepperDown.clipsToBounds = true
        stepperDown.layer.borderWidth = 1.0
        stepperDown.layer.borderColor = stepperLabel.textColor.cgColor
        stepperDown.setTitleColor(UIColor.white, for: UIControlState.highlighted)

        
        stepperUp.layer.cornerRadius = 0.5 * stepperUp.bounds.size.width
        stepperUp.clipsToBounds = true
        stepperUp.layer.borderWidth = 1.0
        stepperUp.layer.borderColor = stepperLabel.textColor.cgColor
        stepperUp.setTitleColor(UIColor.white, for: UIControlState.highlighted)
        
        stepper = KWStepper(decrementButton: stepperDown, incrementButton: stepperUp)
        
        stepper.autoRepeatInterval = 0.2
        stepper.wraps = false
        stepper.minimumValue = 0
        stepper.maximumValue = 20
        stepper.value = 0
        stepper.incrementStepValue = 1
        stepper.decrementStepValue = 1
        
        stepper.valueChangedCallback = { stepper in
            
            print("StepperChange: \(stepper.value)")
            let volume = Int(stepper.value)
            
            self.stepperLabel.text = "\(volume * 5)%"
            
            ServerFarm.doCommand(zone: self.pageZone, sourceCmd: "\(ServerFarm.format.sourceCmd.volume)\(volume)", globalCmd: nil) {
                (success: Bool) in
                if (success) {
                    // self.updatePageStatusUI()
                }
                
            }
        }
    }

    func togglePowerIndicator() {
        if (self.buttonPower.backgroundColor == UIColor.lightGray) {
            self.buttonPower.backgroundColor = .green
        } else {
            self.buttonPower.backgroundColor = .lightGray
        }
    }
    
    func updatePageStatusUI() {
        
        ServerFarm.checkConnection(){
            (result: Bool) in
            
            ServerFarm.updateZone(index: self.pageZone) {
             (result: ZoneStatus) in
                 print("UPDATE UI: \(result)")
                
                 if (result.number != self.pageZone) {
                     return
                 }
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {

                     // Power Status
                     if (result.power) {
                        self.buttonPower.backgroundColor = .green
                        self.stepperView.layer.opacity = 1
                        self.switchMute.layer.opacity = 1
                        self.labelMute.layer.opacity = 1

                     } else {
                         self.buttonPower.backgroundColor = .lightGray
                        self.stepperView.layer.opacity = 0
                        self.switchMute.layer.opacity = 0
                        self.labelMute.layer.opacity = 0
                     }
                }, completion: { (success:Bool) in
                })
                
                 // Source
                 if (result.source > 0 && result.power) {
                     self.segmentSource.selectedSegmentIndex = self.getSegementFromSource(source: result.source)!
                 } else {
                    self.segmentSource.selectedSegmentIndex = UISegmentedControlNoSegment
                 }

                // Volume
                 if (result.volume > 0 && self.pageZone != ServerFarm.format.zone.mediaroom) {

                    self.stepper.value = Double(result.volume)
                    self.stepperLabel.text = "\(Int(100*Double(result.volume)/20))%"
                 }
                
                // Mute
                if (self.pageZone != ServerFarm.format.zone.mediaroom) {
                    self.switchMute.setOn(result.mute && result.power, animated: true)
                }
            }
        }
    }
    
    
    func getCurrentPageZone() -> Int! {
        var zone: Int!
        
        switch self.restorationIdentifier! {
        case "kitchenView":
            zone = ServerFarm.format.zone.kitchen
            break
        case "familyRoomView":
            zone = ServerFarm.format.zone.familyroom
            break
        case "diningRoomView":
            zone = ServerFarm.format.zone.living
            break
        case "upstairsBathView":
            zone = ServerFarm.format.zone.bathup
            break
        case "guestBathView":
            zone = ServerFarm.format.zone.bathdown
            break
        case "patioView":
            zone = ServerFarm.format.zone.patio
            break
        case "basementView":
            zone = ServerFarm.format.zone.mediaroom
            break
        default:
            print(self.restorationIdentifier!)
            zone = -1
        }
        return zone
    }

    
    func getSegementFromSource(source: Int) -> Int? {
        var segment: Int?

        switch source {
        case ServerFarm.format.source.tuner1:
            segment = 0
            break
        case ServerFarm.format.source.sonos:
            segment = 1
            break
        case ServerFarm.format.source.tv:
            segment = 2
            break
        default:
            break;
        }  //Switch
    
        return segment

    }
    
   
}
