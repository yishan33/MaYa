//
//  MYConnectManager.swift
//  MaYa
//
//  Created by liufushan on 2023/6/9.
//

import Foundation

#if os(iOS)
// MARK: - iOS

class MYConnectManager: NSObject {
    
    static var instance = MYConnectManager()
    
    var portNumber: Int?
    var connectedDeviceID: NSNumber?
    var listenChannel: MYListenChannel?
    var serverManager = MYServerMananger()
    var notifyCenter: MYNotifySerializer?
    
    func connect(portNumber: Int) {
        self.portNumber = portNumber
        self.listenChannel = MYListenChannel()
        self.listenChannel?.listen(onPort: in_port_t(portNumber), iPv4Address: INADDR_LOOPBACK, callback: { error in
            print(error);
            self.notifyCenter = MYNotifySerializer(socketChannel: (self.listenChannel?.firstSocketChannel)!)
        })
    }
    
    var isConnected: Bool {
        return self.listenChannel != nil
    }
    
    /** Closes the USB connectin */
    func disconnect() {
        //
    }
    
    func broadcast(data: Data, type: UInt32, completion: ((_ success: Bool) -> Void)? = nil) {
        if self.notifyCenter != nil {
            self.notifyCenter?.broadcast(data: data)
        } else {
            completion?(false)
        }
    }
    
}


// TODO: 连接状态怎么做 eetest

#elseif os(OSX)

// MARK: - Mac
class MYConnectManager: NSObject {
    
    static var instance = MYConnectManager()
    
    // MARK: Properties
    var delegate: PTManagerDelegate?
    fileprivate var portNumber: Int?
    var connectingToDeviceID: NSNumber?
    var connectedDeviceID: NSNumber?
    var connectedDeviceProperties: NSDictionary?
    var connectedChannel: MYConnectChannel?
    
    /** The interval for rechecking whether or not an iOS device is connected */
    let reconnectDelay: TimeInterval = 1.0
    
    // MARK: Methods
    
    /** Begins to look for a device and connects when it finds one */
    func connect(portNumber: Int) {
        self.portNumber = portNumber
        self.startListeningForDevices()
//        self.enqueueConnectToLocalIPv4Port()
    }
    
    /** Sends data to the connected device */
    func sendData(data: Data, type: UInt32, completion: ((_ success: Bool) -> Void)? = nil) {
        let data = data as NSData
        if connectedChannel != nil {
            connectedChannel?.sendFrame(ofType: type, tag: PTFrameNoTag, withPayload: data.createReferencingDispatchData(), callback: { (error) in
                completion?(true)
            })
        } else {
            completion?(false)
        }
    }
}

extension MYConnectManager {
    
    fileprivate func startListeningForDevices() {
        // Grab the notification center instance
        let nc = NotificationCenter.default
        
        // Add an observer for when the device attaches
        nc.addObserver(forName: NSNotification.Name.PTUSBDeviceDidAttach, object: PTUSBHub.shared(), queue: nil) { (note) in
            
            // Grab the device ID from the user info
            let deviceID = note.userInfo!["DeviceID"] as! NSNumber
            print("Attached to device: \(deviceID)")
            
            // Update our properties on our thread
            if self.connectingToDeviceID == nil || !deviceID.isEqual(to: self.connectingToDeviceID) {
                self.connectingToDeviceID = deviceID
                self.connectedDeviceProperties = (note.userInfo?["Properties"] as? NSDictionary)
                self.enqueueConnectToUSBDevice()
            }
        }
        
        // Add an observer for when the device detaches
        nc.addObserver(forName: NSNotification.Name.PTUSBDeviceDidDetach, object: PTUSBHub.shared(), queue: nil) { (note) in
            
            // Grab the device ID from the user info
            let deviceID = note.userInfo!["DeviceID"] as! NSNumber
            print("Detached from device: \(deviceID)")
            
            // Update our properties on our thread
            if self.connectingToDeviceID!.isEqual(to: deviceID) {
                self.connectedDeviceProperties = nil
                self.connectingToDeviceID = nil
                if self.connectedChannel != nil {
                    self.connectedChannel?.close()
                }
            }
        }
    }
    
    // Runs when the device disconnects
    fileprivate func didDisconnect(fromDevice deviceID: NSNumber) {
        print("Disconnected from device")
        delegate?.peertalk(didChangeConnection: false)
        
        // Notify the class that the device has changed
        if connectedDeviceID!.isEqual(to: deviceID) {
            self.willChangeValue(forKey: "connectedDeviceID")
            connectedDeviceID = nil
            self.didChangeValue(forKey: "connectedDeviceID")
        }
    }
    
    @objc fileprivate func enqueueConnectToUSBDevice() {
        self.connectToUSBDevice()
    }
    
    fileprivate func connectToUSBDevice() {
        
        // Create the new channel
        let channel = MYConnectChannel(delegate: self)
        channel?.delegate = self
        
        // Connect to the device
        channel?.connect(toPort: Int32(portNumber!), overUSBHub: PTUSBHub.shared(), deviceID: connectingToDeviceID, callback: { (error) in
            if error != nil {
                print(error!.localizedDescription)
                // Reconnet to the device
                if let connected = channel?.isConnected, connected == false {
                    self.perform(#selector(self.enqueueConnectToUSBDevice), with: nil, afterDelay: self.reconnectDelay)
                }
            } else {
                // Update connected device properties
                self.connectedDeviceID = self.connectingToDeviceID
                self.connectedChannel = channel
//                self.delegate?.peertalk(didChangeConnection: true)
                // Check the device properties
                print("\(self.connectedDeviceProperties!)")
            }
        })
    }
}

extension MYConnectManager: PTChannelDelegate {
    func ioFrameChannel(_ channel: PTChannel, didReceiveFrameOfType type: UInt32, tag: UInt32, payload: PTData) {
        // Creates the data
        let dispatchData = payload.dispatchData as DispatchData
        let data = NSData(contentsOfDispatchData: dispatchData as __DispatchData) as Data
//        delegate?.peertalk(didReceiveData: data, ofType: type, onChannel: channel)
        print("MYConnectManager didReceiveData")
    }
}

extension MYConnectManager: MYConnectChannelDelegate {
    func onChannel(_ channel: MYConnectChannel!, didReceiveEnd type: UInt32) {
        
    }
    
    func onChannel(_ channel: MYConnectChannel!, didEndWithError error: Error!) {
        
    }
    
    func onChannel(_ channel: MYConnectChannel!, didReceiveDataType type: UInt32, tag: UInt32, payload: PTData!) {
        print("MYConnectManager MYConnectChannelDelegate didReceiveData")
    }
}

#endif

// MARK: - Data extension for conversion
extension Data {
    
    /** Unarchive data into an object. It will be returned as type `Any` but you can cast it into the correct type. */
    func convert() -> Any {
        return NSKeyedUnarchiver.unarchiveObject(with: self)
    }
    
    /** Converts an object into Data using the NSKeyedArchiver */
    static func toData(object: Any) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: object)
    }
    
}
