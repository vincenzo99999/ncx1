//
//  MessageView.swift
//  ChatApp
//
//  Created by Vincenzo Eboli on 26/03/24.
//

import Foundation
import SwiftUI
struct MessageView:View{
    let message:ChatMessage
    var body:some View {
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
        }
    }
}
 


