//
//  Helper.swift
//  MaYa
//
//  Created by lfs on 2023/1/8.
//

import Foundation

#if os(iOS)

import UIKit

typealias MYImage = UIImage
let Global_deviceID = "iOS"

#elseif os(OSX)

import Cocoa

typealias MYImage = NSImage
let Global_deviceID = "MAC"

#endif

//let ScreenW = UIScreen.main.bounds.size.width
let ScreenH = CGFloat(800)

func jsonToData(jsonDic:Dictionary<String, Any>) -> Data? {
    if (!JSONSerialization.isValidJSONObject(jsonDic)) {
        print("is not a valid json object")
        return nil
    }
    
    //利用自带的json库转换成Data
    //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
    let data = try? JSONSerialization.data(withJSONObject: jsonDic, options: [])
    let str = String(data:data!, encoding: String.Encoding.utf8) //Data转换成String打印输出
    print("Json Str:\(str!)") //输出json字符串
    
    return data
}

func dataToJson(data:Data) -> Dictionary<String, Any>?{
    do {
        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        let dic = json as! Dictionary<String, Any>
        return dic
    } catch _ {
        print("失败")
        return nil
    }
}
