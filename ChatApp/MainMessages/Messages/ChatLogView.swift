//
//  ChatLogView.swift
//  ChatApp
//
//  Created by Vincenzo Eboli on 24/03/24.
//

import Foundation
import SwiftUI

struct ChatLogView:View{
    let chatUser:ChatUser?
    @State var isChatFocused=""
    @ObservedObject var vm:ChatLogViewModel
    
    init(chatUser:ChatUser?){
        self.chatUser=chatUser
        self.vm = .init(chatUser:chatUser)
    }
    var body:some View{
        ZStack{
            Text(vm.errorMessage)
            messagesView
            VStack{
                Spacer()
                chatBottomBar.background(Color.white)
            }
        }
    }
    private var chatBottomBar:some View{
        VStack{
            HStack(spacing:16){
                Image(systemName: "photo.on.rectangle").font(.system(size: 24)).foregroundColor(Color(.darkGray))
                //use a textEditor instead
                TextField("Message", text: $vm.chatText)
                Button{
                    vm.handleSend()
                } label:{
                    Text("Send").foregroundColor(.white)
                }.padding(.horizontal)
                    .padding(.vertical)
                    .background(Color.blue)
                    .cornerRadius(5)
            }.padding(.horizontal)
                .padding(.vertical,8)
        }
    }
    private var messagesView:some View{
        VStack{
            
            ScrollView {
                ForEach(vm.chatMessages)
                { message in
                    VStack{
                        if message.fromId==FirebaseManager.shared.auth.currentUser?.uid{
                            
                            HStack
                            {
                                Spacer ()
                                HStack {
                                    Text (message.text)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background (Color.blue)
                                        .cornerRadius (8)
                                }
                            }
                        }else {
                            HStack {
                                HStack {
                                    Text (message.text)
                                        .foregroundColor(.black)
                                }
                                .padding()
                                .background(Color(.lightGray))
                                .cornerRadius(8)
                                Spacer ()
                            }
                            .padding(.horizontal)
                            .padding(.top,8)
                        }
                        HStack{ Spacer ()}
                    }.background(Color.white)
                        .navigationTitle(chatUser?.email ?? "")
                        .navigationBarTitleDisplayMode(.inline)
                }.padding(.bottom,65)
                
                
                
            }
        }
    }
}

#Preview {
    NavigationView{
        ChatLogView(chatUser: .init(data: ["uid":"HHD5PiaPdfZ3IMZUcVRRg1RPghB2","email":"vincenzo5@gmail.com"]))
    }
}
