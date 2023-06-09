//
//  ViewModel.swift
//  MaYa
//
//  Created by lfs on 2023/1/8.
//

import Foundation

class MYViewModel: ObservableObject {
    
    @Published var connectStatus = false
    @Published var sendImg: MYImage?
    @Published var receiveImg: MYImage?
    
    @Published var receiveStr = ""
    @Published var sendStr = "测试str"
    
    @Published var receiveNum = 0
    @Published var sendNum = 653
    
    @Published var receiveDict = ["":""]
    @Published var sendDict = ["testKey":"testValue"]
    
    @Published var infos = [ChatCellInfo(message: "你好", isMy: true),
                            ChatCellInfo(message: "你好", isMy: false),
                            ChatCellInfo(message: "你叫啥", isMy: true),
                            ChatCellInfo(message: "我叫Lucy", isMy: false)]
    
//    var requestHandler = PTRequestSerializer()
    var requestHandler = MYRequestSerializer()
    
    static let instance = MYViewModel()
//    let ptManager = PTManager.instance
    let myConnectManager = MYConnectManager.instance
    var deviceID = Global_deviceID
    
    init() {
//        ptManager.delegate = self
//        ptManager.connect(portNumber: PORT_NUMBER)
        myConnectManager.connect(portNumber: PORT_NUMBER)
    }
    
    func connectAgain() {
//        ptManager.connect(portNumber: PORT_NUMBER)
        myConnectManager.connect(portNumber: PORT_NUMBER)
    }
    
//    func sendMessage() {
//        if ptManager.isConnected {
//            ptManager.sendObject(object: sendStr, type: PTType.string.rawValue)
//            logMessage(msg: "send string: \(sendStr)")
//        }
//    }
//
//    func sendNumber() {
//        if ptManager.isConnected {
//            ptManager.sendObject(object: sendNum, type: PTType.number.rawValue)
//            logMessage(msg: "send num: \(sendNum)")
//        }
//    }
    
    func sendDictionary() {
//        if ptManager.isConnected {
            #if os(OSX)
            myConnectManager.sendData(data: jsonToData(jsonDic: sendDict) ?? Data(), type: PTType.json.rawValue)
            logMessage(msg: "send dictionary: \(sendDict)")
            #elseif os(iOS)
            myConnectManager.notifyCenter?.broadcast(data: jsonToData(jsonDic: sendDict) ?? Data())
            #endif
//        }
    }
    
//    func sendImage() {
//        if ptManager.isConnected {
//            ptManager.sendObject(object: sendImg, type: PTType.image.rawValue)
//            logMessage(msg: "send string: \(sendImg)")
//        }
//    }
    
    func sendTest() {
//        if ptManager.isConnected {
            self.requestHandler.request(path: "/getUsers", params: ["":""]) { json in
                print("成功回调 json \(json)")
            }
            logMessage(msg: "send request: getUsers")
//        }
    }
}

extension MYViewModel: PTManagerDelegate {
    func peertalk(shouldAcceptDataOfType type: UInt32) -> Bool {
        return true
    }
    
    func peertalk(didReceiveData data: Data, ofType type: UInt32, onChannel channel: Any) {
        if type == PTType.string.rawValue {
            if let receiveStr = data.convert() as? String {
                logMessage(msg: "receive string: \(receiveStr)")
                let info = ChatCellInfo(message: receiveStr, isMy: false)
                infos.append(info)
            }
        } else if type == PTType.number.rawValue {
            let result = data.convert() as! Int
            receiveNum = result
            logMessage(msg: "receive num: \(receiveNum)")
        } else if type == PTType.image.rawValue {
            receiveImg = MYImage(data: data)
            logMessage(msg: "receive img: \(data)")
        } else if type == PTType.json.rawValue {
            let receiveDict = dataToJson(data: data)
            logMessage(msg: "receive dict: \(receiveDict)")
        }
    }
    
    func logMessage(msg:String) {
        print("\(deviceID)-> \(msg)")
    }
    
    func peertalk(didChangeConnection connected: Bool) {
        print("Connection: \(connected)")
        connectStatus = connected
    }
}
