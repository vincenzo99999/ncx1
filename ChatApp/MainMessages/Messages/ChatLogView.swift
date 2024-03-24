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
    var body:some View{
        ScrollView{
            ScrollView {
                ForEach(0..<10)
                { num in
                    HStack {
                        Spacer ()
                        HStack {
                            Text ("FAKE MESSAGE FOR NOW")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background (Color.blue)
                        .cornerRadius (8)
                        .padding(.horizontal)
                        .padding (.top, 8)
                    }
                    HStack{ Spacer ()}
                }.background(Color(.init(white:0.95,alpha: 1)))
                    .navigationTitle(chatUser?.email ?? "")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    NavigationView{
        ChatLogView(chatUser: .init(data: ["uid":"real user id","email":"vincenzo@gmail.com"]))
    }
}
