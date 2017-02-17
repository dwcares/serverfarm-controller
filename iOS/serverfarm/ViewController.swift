//
//  ViewController.swift
//  serverfarm
//
//  Created by Washington Family on 2/9/17.
//  Copyright © 2017 Washington. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {
    
    //MARK: Properties
    
    var pageZone: Int!
    
    @IBOutlet weak var buttonPower: UIButton!
    
    @IBOutlet weak var switchMute: UISwitch!
    @IBOutlet weak var segmentSource: UISegmentedControl!
    var page: String!
    
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var volumeStepperButton: UIStepper!
    @IBAction func volumeStepperChanged(_ sender: UIStepper) {
        print("StepperChange:  :\(sender.value)")
        let volume = Int(sender.value)
        
        if (self.pageZone == ServerFarm.format.zone.mediaroom) {
            
            if (sender.value == 0) {
                print("down")
                ServerFarm.doCommand(zone: self.pageZone, sourceCmd: nil, globalCmd: ServerFarm.format.globalCmd.mvolumedown)  {
                    _ in

                }
            } else {
                print("up")
                ServerFarm.doCommand(zone: self.pageZone, sourceCmd: nil, globalCmd: ServerFarm.format.globalCmd.mvolumeup)  {
                    _ in
                }
            }
            sender.value = 1; // reset
          
        } else {
            ServerFarm.doCommand(zone: pageZone, sourceCmd: "\(ServerFarm.format.sourceCmd.volume)\(volume)", globalCmd: nil) {
                (success: Bool) in
                if (success) { self.updatePageStatusUI() }
                
            }
        }
    }
    @IBAction func togglePowerAction(_ sender: UIButton) {
        print("Toggle power")
        ServerFarm.doCommand(zone: pageZone, sourceCmd: ServerFarm.format.sourceCmd.power, globalCmd: nil)  {
            (success: Bool) in
            if (success) {
                self.updatePageStatusUI()
                
            }
        
        }
    }
    
    @IBAction func muteChanged(_ sender: UISwitch) {
 
        if (self.pageZone == ServerFarm.format.zone.mediaroom) {
            ServerFarm.doCommand(zone: self.pageZone, sourceCmd: nil, globalCmd: ServerFarm.format.globalCmd.mmute)  {
                (success: Bool) in
                if (success) { print("Muted Marantz") }
                
            }
        }else {
            ServerFarm.doCommand(zone: pageZone, sourceCmd: ServerFarm.format.sourceCmd.mute, globalCmd: nil)  {
                (success: Bool) in
                if (success) {
                    self.updatePageStatusUI()
                }
            }
        }
        
    }
   
    @IBAction func indexChanged(_ sender : UISegmentedControl) {

        var command = ""
        if (pageZone == ServerFarm.format.zone.mediaroom) {
            switch sender.selectedSegmentIndex {
            case 0:
                command = ServerFarm.format.sourceCmd.bluray
            case 1:
                command = ServerFarm.format.sourceCmd.tv
            case 2:
                command = ServerFarm.format.sourceCmd.xbox
            case 3:
                command = ServerFarm.format.sourceCmd.sonos
            default:
                break;
            }  //Switch
            
        } else {
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
        }

        
        ServerFarm.doCommand(zone: pageZone, sourceCmd: command, globalCmd: nil)  {
            (success: Bool) in
            if (success) {
                if (self.pageZone == ServerFarm.format.zone.mediaroom && sender.selectedSegmentIndex == 2) {
                    ServerFarm.doCommand(zone: self.pageZone, sourceCmd: nil, globalCmd: ServerFarm.format.globalCmd.xbox)  {
                        (success: Bool) in
                        if (success) {
                            self.updatePageStatusUI()
                        }
                    }

                } else {
                    self.updatePageStatusUI()

                }
                
            }
            
        }
        
    }
    
    /////////////

    override func viewDidLoad() {
        super.viewDidLoad()

        // Make the power button round
        buttonPower.layer.cornerRadius = 0.5 * buttonPower.bounds.size.width
        buttonPower.clipsToBounds = true
        
        pageZone = getCurrentPageZone()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updatePageStatusUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updatePageStatusUI() {
        
        ServerFarm.checkConnection() {
            (result: Bool) in
            
            ServerFarm.updateZone(index: self.pageZone) {
             (result: ZoneStatus) in
             print("UPDATE UI: \(result)")
            
             if (result.number != self.pageZone) {
                 return
             }
            
             // Power Status
             if (result.power) {
                 self.buttonPower.backgroundColor = .green
             } else {
                 self.buttonPower.backgroundColor = .lightGray
             }
            
             // Source
             if (result.source > 0 && result.power) {
                 self.segmentSource.selectedSegmentIndex = self.getSegementFromSource(source: result.source)!
             } else {
                self.segmentSource.selectedSegmentIndex = UISegmentedControlNoSegment
             }

             if (result.volume > 0 && self.pageZone != ServerFarm.format.zone.mediaroom) {
                self.volumeStepperButton.value = Double(result.volume)
                self.volumeLabel.text = "Volume \(Int(100*Double(result.volume)/20))%"
             }
                
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
            zone = ServerFarm.format.zone.dining
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
        if (pageZone == ServerFarm.format.zone.mediaroom) {
            switch source {
            case ServerFarm.format.source.bluray:
                segment = 0
                break
            case ServerFarm.format.source.tv:
                segment = 1
                break
            case ServerFarm.format.source.xbox:
                segment = 2
                break
            case ServerFarm.format.source.sonos:
                segment = 3
            default:
                break;
            }  //Switch
            
        } else {
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
        }
        
        return segment

    }
    
      
}
