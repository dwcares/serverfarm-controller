//
//  ServerFarm.swift
//  serverfarm
//
//  Created by Washington Family on 2/9/17.
//  Copyright © 2017 Washington. All rights reserved.
//

import Foundation
import SocketIO

class ServerFarm {
        
    struct format {
        struct type {
            static var execute = "!"
            static var query = "?"
            static var pattern = "#(\\d?\\d)+ZS PR(\\d)+ SS(\\d?\\d)+ VO(\\d?\\d)+ MU(\\d)+"
        }
        struct zone {
            static var na = 0
            static var familyroom = 1
            static var patio = 2
            static var mediaroom = 3
            static var kitchen = 4
            static var bathup = 5
            static var bathdown = 6
            static var dining = 7
            static var living = 8
        }
        struct source {
            static var na = 0
            static var tv = 1
            static var bluray = 2
            static var sonos = 3
            static var tuner1 = 5
            static var tuner2 = 6
            static var xbox = 8
        }
        struct sourceCmd {
            static var tv = "MK0X3"
            static var bluray = "MK0X4"
            static var sonos = "MK0X5"
            static var tuner1 = "MK0X7"
            static var tuner2 = "MK0X8"
            static var marantz = "MK0X9"
            static var xbox = "MK0X10"
            
            static var power = "PT"
            static var mute = "MT"
            static var volumeup = "MK0X1"
            static var volumedown = "MK0X2"
            static var volume = "VO" 
            static var channelup = "MK0X11"
            static var channeldown = "MK0X12"
        }
        struct globalCmd {
            static var mvolumeup = "130MC"
            static var mvolumedown = "131MC"
            static var mmute = "133MC"
            static var xbox = "134MC"
            static var allzonesoff = "AO"
            static var zoneautoupdateon = "ZA1"
            static var zoneautoupdateoff = "ZA0"
            static var zoneperiodic = "ZP20"
        }
        struct sourceQuery {
            static var status = "ZS"
            static var autoupdate = "ZA"
        }
    }
    
    static var ip = "192.168.2.84"
   
    static var socket: SocketIOClient?
    
    static func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
        return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
    }
    
    static func checkConnection(completion: @escaping (Bool) -> Void)  {
    
        if (socket?.status != SocketIOClientStatus.connected) {
            socket?.on("connect") { data, ack in
                completion(true)
            }
            
        } else {
            completion(true)
        }
    }
    static func initServer (completion: @escaping (Bool) -> Void) {
        var connected = false
        
        socket = SocketIOClient(socketURL: URL(string: "http://\(ip):3000")!)

        print("Connecting...")
        socket?.on("connect") {data, ack in
            print("Connected")
            connected = true
            completion(true)

        }
        
        socket?.on("disconnect") { data, ack in
            print("Disconnected")
            connected = false
        }

        
        _ = setTimeout(15) {
            if (!connected) {
                completion(false)
            }
        }
        
        socket?.connect()
        
   

    }
    
    static func updateZone(index: Int, completion: @escaping (ZoneStatus) -> Void) {

        var queryString = self.format.type.query
        queryString = queryString + String(index) + self.format.sourceQuery.status
        queryString = queryString + "+"
        print(queryString)
        socket?.emit("tx", queryString)
    
        socket?.on("rx") {data, ack in
            let result = data[0] as! String
            socket?.off("rx")
            print(result)

            completion(ZoneStatus(pattern: result))
        }
    }
    
    static func doQuery(zone: Int?, sourceQuery: String?) {
        var queryString = self.format.type.query
        queryString = queryString + String(zone!) + sourceQuery!
        queryString = queryString + "+"
        print(queryString)
        socket?.emit("tx", queryString)
    
    }
    
    static func doCommand(zone: Int?, sourceCmd: String?, globalCmd: String?, completion: @escaping (Bool) -> Void) {

        var commandString = self.format.type.execute
        
        
        if (globalCmd != nil) {
            commandString = commandString + globalCmd!
        } else {
            commandString = commandString + String(zone!) + sourceCmd!
        }
        
        commandString = commandString + "+"
        print(commandString)
        socket?.emit("tx", commandString)
        
        socket?.on("rx") {data, ack in
            let result = data[0] as! String
            socket?.off("rx")
            
            let status = (result.contains("OK"))
            completion(status)
        }
 
    }
    
    static func getSourceCommandFromSourceIndex(source: Int) -> String {
        var command = ""
        
        switch source {
        case 1:
            command = format.sourceCmd.tv
            break
        case 2:
            command = format.sourceCmd.bluray
            break
        case 3:
            command = format.sourceCmd.sonos
            break
        case 4:
            break
        case 5:
            command = format.sourceCmd.tuner1
            break
        case 6:
            command = format.sourceCmd.tuner2
            break
        case 7:
            break
        case 8:
            command = format.sourceCmd.xbox
            break
        default: break
            
        }
        return command
    }
}

struct ZoneStatus {
    var number: Int
    var power: Bool
    var volume: Int
    var source: Int
    var mute: Bool
    
    init(number: Int, power: Bool, source: Int, volume: Int, mute: Bool) {
        self.number = number
        self.power = power
        self.source = source
        self.volume = volume
        self.mute = mute
        
    }
    
    init(pattern: String) {
        var patternGroups = pattern.capturedGroups(withRegex: ServerFarm.format.type.pattern)
        
        if (patternGroups.count>0) {
            self.number = Int(patternGroups[0])!
            self.power = patternGroups[1].toBool()!
            self.source = Int(patternGroups[2])!
            self.volume = Int(patternGroups[3])!
            self.mute = patternGroups[4].toBool()!
        } else {
            self.number = 0
            self.power = false
            self.source = 0
            self.volume = 0
            self.mute = false
        }
    }
}


extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    


    func capturedGroups(withRegex pattern: String) -> [String] {
        var results = [String]()
        
        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return results
        }
        
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.characters.count))
        
        guard let match = matches.first else { return results }
        
        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }
        
        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.rangeAt(i)
            let matchedString = (self as NSString).substring(with: capturedGroupIndex)
            results.append(matchedString)
        }
        
        return results
    }
    
    func matches(withRegex pattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

