//
//  MYNotifySerializer.swift
//  MaYa
//
//  Created by liufushan on 2023/6/9.
//

import Foundation


class MYNotifySerializer : NSObject {
    
    let socketChannel: MYSocketChannel
    
    init(socketChannel: MYSocketChannel) {
        self.socketChannel = socketChannel
    }
    
    func broadcast(json:[String:Any]) {
        // broadcast notify
        let json = ["":""]
        let data = jsonToData(jsonDic: json) ?? Data()
        self.socketChannel.sendFrame(ofType: 102, tag: PTFrameNoTag, withPayload: (data as NSData).createReferencingDispatchData(), callback: { error in
            if (error == nil) {
                print("broadcast success!")
            }
        })
    }
    
    func broadcast(data:Data) {
        // broadcast notify
        let data = data
        self.socketChannel.sendFrame(ofType: 102, tag: PTFrameNoTag, withPayload: (data as NSData).createReferencingDispatchData(), callback: { error in
            if (error == nil) {
                print("broadcast success!")
            }
        })
    }
}
