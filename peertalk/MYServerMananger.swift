//
//  PTServerManager.swift
//  MaYa
//
//  Created by liufushan on 2023/6/8.
//

import Foundation

@objc class MYServerMananger : NSObject {

    @objc func ioFrameChannel(_ channel: MYSocketChannel!, didReceiveFrameOfType type: UInt32, tag: UInt32, payload: PTData!) {
        // Creates the data
        let dispatchData = payload.dispatchData as DispatchData
        let data = NSData(contentsOfDispatchData: dispatchData as __DispatchData) as Data
        
        if type == PTType.json.rawValue {
            let receiveDict = dataToJson(data: data)
            print("receive dict : \(receiveDict)")
            
            let json = self.getRspWithReq(reqJson: receiveDict ?? ["":""])
            let data = jsonToData(jsonDic: json) ?? Data()
            channel.sendFrame(ofType: 102, tag: PTFrameNoTag, withPayload: (data as NSData).createReferencingDispatchData(), callback: { error in
                if (error == nil) {
                    print("sendFrameOfType success!")
                }
            })
        }
    }
    
    func getRspWithReq(reqJson:[String:Any]) -> [String:Any] {
        let path = reqJson["path"] as? String
        let params = reqJson["params"] as? [String:Any]
        if path == "/getUsers" {
            let rsp = ["path":path as Any, "code": 0, "msg": "success", "data":["nick", "lucy", "forthon"]] as [String : Any]
            return rsp
        }
        return ["":""]
    }
    
}

