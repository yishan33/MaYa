//
//  PTRequestSer.swift
//  MaYa
//
//  Created by liufushan on 2023/6/7.
//

import Foundation

class MYRequestSerializer : NSObject {
    let kMYServerPort = 4986
    var successHandler: (([String:Any]) -> Void)?
    var faileHandler: ((Error) -> Void)?
    var connectChannel: MYConnectChannel?
    
    func request(path:String, params:[String:Any], onSuccess:@escaping ([String:Any]) -> Void) {
        self.successHandler = onSuccess
        self.connectChannel = MYConnectChannel(delegate: self)
        self.connectChannel?.delegate = self
        
        // Connect to the device
        self.connectChannel?.connect(toPort: Int32(kMYServerPort), overUSBHub: PTUSBHub.shared(), deviceID: MYConnectManager.instance.connectedDeviceID, callback: { (error) in
            guard error == nil else {
                print("connectedDeviceID error: \(error)")
                return
            }
            let json = ["path":path, "params":params] as [String : Any]
            let data = jsonToData(jsonDic: json) ?? Data()
            self.connectChannel?.sendFrame(ofType: 102, tag: PTFrameNoTag, withPayload: (data as NSData).createReferencingDispatchData(), callback: { error in
                if (error == nil) {
                    print("消息发送成功!")
                }
            })
        })
    }
}
                         
extension MYRequestSerializer: MYConnectChannelDelegate {
    func onChannel(_ channel: MYConnectChannel!, didReceiveEnd type: UInt32) {
        
    }
    
    func onChannel(_ channel: MYConnectChannel!, didEndWithError error: Error!) {
        
    }
    
    func onChannel(_ channel: MYConnectChannel!, didReceiveDataType type: UInt32, tag: UInt32, payload: PTData!) {
        let dispatchData = payload.dispatchData as DispatchData
        let data = NSData(contentsOfDispatchData: dispatchData as __DispatchData) as Data
        
        if type == PTType.json.rawValue {
            let receiveDict = dataToJson(data: data)
            print("receive response: \(String(describing: receiveDict))")
            
            if (self.successHandler != nil) {
                self.successHandler!(receiveDict ?? ["":""])
            }
            
            self.connectChannel?.close()
        }
    }
}

