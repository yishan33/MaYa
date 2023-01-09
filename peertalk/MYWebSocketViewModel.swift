//
//  MYWebSocketViewModel.swift
//  MaYa
//
//  Created by lfs on 2023/1/9.
//

import Foundation
import Starscream


class MYWebSocketViewModel: ObservableObject, WebSocketDelegate {
    
    var socket: WebSocket
    var isConnected: Bool = false
    
    init() {
        var request = URLRequest(url: URL(string: "http://localhost:8080")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        
        socket.onEvent = { event in
            switch event {
                // handle events just like above...
            default: print("event")
            }
        }
    }
    
//    func defaultSetting() {
//        var request = URLRequest(url: URL(string: "http://localhost:8080")!)
//        request.timeoutInterval = 5
//        socket = WebSocket(request: request)
//        socket.delegate = self
//        socket.connect()
//    }
    
    func sendMessage(msg:String) {
        socket.write(string: "Hi Server!")
    }
    
    func handleError(error:Error?) {
        
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error:error)
        }
    }
    
}
