//
//  MYChatView.swift
//  MaYa
//
//  Created by lfs on 2023/1/8.
//

import SwiftUI

struct MYChatView: View {
    @StateObject var viewModel = MYViewModel.instance
    
    var body: some View {
        VStack {
//            HStack {
//                Circle().size(width: 20, height: 20).foregroundColor(viewModel.connectStatus ? .green : .red)
//                Button("重连") {
//                    viewModel.connectAgain()
//                }
//            }
//            Text(viewModel.receiveStr).foregroundColor(.black).font(.callout)
//                .frame(width: 400, height: ScreenH / 2)
            ChatListView()
//                .background(.gray.opacity(0.3))
//                .frame(width: 400, height: ScreenH / 2)
            HStack(spacing: 8) {
                SendButton(title: "发送文字") {
//                    viewModel.sendMessage()
                }
                SendButton(title: "发送数字") {
//                    viewModel.sendNumber()
                }
                SendButton(title: "发送字典") {
                    viewModel.sendDictionary()
                }
            }
            HStack(spacing: 8) {
                SendButton(title: "发送图片") {
                    viewModel.sendTest()
                }
                SendButton(title: "发送请求") {
                    viewModel.sendTest()
                }
                SendButton(title: "发送视频") {
                    viewModel.sendDictionary()
                }
            }
        }
        .padding()
        .background(.gray.opacity(0.3))
    }
}

struct ChatListView: View {
    
    @StateObject var viewModel = MYViewModel.instance
    
    var body: some View {
        ScrollView {
            ForEach(0..<viewModel.infos.count, id: \.self) { index in
                ChatListCellView(info: viewModel.infos[index])
            }
        }
    }
}

class ChatCellInfo {
//    let avatar: String?
    let message: String
    let isMy: Bool
    init(message: String, isMy: Bool) {
        self.message = message
        self.isMy = isMy
    }
}

struct ChatListCellView: View {
    
    let info: ChatCellInfo
    
    init(info: ChatCellInfo) {
        self.info = info
    }
    
    var body: some View {
        HStack {
            if info.isMy {
                Spacer()
                Text(info.message).font(.system(size: 18)).padding(.vertical, 6).padding(.horizontal, 10)
                    .background(.green).cornerRadius(8)
                RoundedRectangle(cornerRadius: 8).frame(width: 36).foregroundColor(.purple.opacity(0.6))
            } else {
                RoundedRectangle(cornerRadius: 8).frame(width: 36).foregroundColor(.orange.opacity(0.6))
                Text(info.message).font(.system(size: 18)).padding(.vertical, 6).padding(.horizontal, 10)
                    .background(.white).cornerRadius(8)
                Spacer()
            }
        }
    }
}


struct SendButton: View {
    
    var title: String
    var actionBlock: () -> Void
    
    init(title: String, actionBlock: @escaping () -> Void) {
        self.title = title
        self.actionBlock = actionBlock
    }
    
    var body: some View {

        Button {
            actionBlock()
        } label: {
            Text(title)
        }
        .foregroundColor(.white)
        .font(.system(size: 20))
        .padding().background(.purple)
        .cornerRadius(8)
    }
}


struct MYChatView_Previews: PreviewProvider {
    static var previews: some View {
        MYChatView()
    }
}
