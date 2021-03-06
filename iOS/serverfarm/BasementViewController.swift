//
//  BasementViewController.swift
//  serverfarm
//
//  Created by Washington Family on 2/20/17.
//  Copyright © 2017 Washington. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import KWStepper


class BasementViewController: RoomViewController {
    
//MARK: Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.stepperView.layer.opacity = 1
        self.switchMute.layer.opacity = 1
        self.labelMute.layer.opacity = 1
        
    }

    @IBAction override func togglePowerAction(_ sender: UIButton) {
        print("Toggle power")
        
        ServerFarm.doCommand(zone: self.pageZone, sourceCmd: ServerFarm.format.sourceCmd.bluray, globalCmd: nil)  {
            (success: Bool) in
            if (success) {
                ServerFarm.setTimeout(0.5, block: { () -> Void in
                    self.updatePageStatusUI()
                })
            }
        }
        
    }
    
    @IBAction override func muteChanged(_ sender: UISwitch) {
        
        ServerFarm.doCommand(zone: self.pageZone, sourceCmd: nil, globalCmd: ServerFarm.format.globalCmd.mmute)  {
            (success: Bool) in
            if (success) { print("Muted Marantz") }
            
        }
        
    }
    
    @IBAction override func indexChanged(_ sender : UISegmentedControl) {
        
        var command = ""
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
        
        
        ServerFarm.doCommand(zone: pageZone, sourceCmd: command, globalCmd: nil)  {
            (success: Bool) in
            if (success) {
                if (sender.selectedSegmentIndex == 2) {
                    ServerFarm.doCommand(zone: self.pageZone, sourceCmd: nil, globalCmd: ServerFarm.format.globalCmd.xbox)  {
                        (success: Bool) in
                        if (success) {
                            ServerFarm.setTimeout(0.5, block: { () -> Void in
                                self.updatePageStatusUI()
                            })
                            
                        }
                    }
                    
                } else {
                    ServerFarm.setTimeout(0.5, block: { () -> Void in
                        self.updatePageStatusUI()
                    })
                    
                }
            }
            
        }
        
    }
    
    override func initStepper() {
        
        super.initStepper()
        
        stepper.autoRepeatInterval = 0.5
        stepper.wraps = true
        stepper.minimumValue = 0
        stepper.maximumValue = 10
        stepper.value = 0
        stepper.incrementStepValue = 1
        stepper.decrementStepValue = 1
        
        stepper.decrementCallback = { stepper in
            print("down")
            ServerFarm.doCommand(zone: self.pageZone, sourceCmd: nil, globalCmd: ServerFarm.format.globalCmd.mvolumedown)  {
                _ in

            }
        }
        
        stepper.incrementCallback = { stepper in
            print("up")
            ServerFarm.doCommand(zone: self.pageZone, sourceCmd: nil, globalCmd: ServerFarm.format.globalCmd.mvolumeup)  {
                _ in
            }
        }
        
        stepper.valueChangedCallback = nil
    }

    
    /////////////
    
    func isZoneOn(completion: @escaping (Bool) -> Void) {
        ServerFarm.checkConnection() {
            (result: Bool) in
            
            ServerFarm.updateZone(index: self.pageZone) {
                (result: ZoneStatus) in
        
                
                if (result.number != self.pageZone) {
                    return
                }
                
                completion (result.power)
            }
        }
    }
    
    override func updatePageStatusUI() {
        
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
                
            }
        }
    }

    
    
    override func getSegementFromSource(source: Int) -> Int? {
        var segment: Int?
        
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
  
        return segment
        
    }
    
    
}
