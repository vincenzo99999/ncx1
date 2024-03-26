//
//  CreateNewMessageView.swift
//  ChatApp
//
//  Created by Vincenzo Eboli on 24/03/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
struct CreateNewMessageView:View{
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    let didSelectNewUser: (ChatUser)->()
    var body:some View{
        NavigationView{
            
            ScrollView{
                ForEach(vm.users,id: \.id){ user in
                    HStack{
                        Button{
                            presentationMode.wrappedValue.dismiss()
                            didSelectNewUser(user)
                                } label:{
                            WebImage(url: URL(string: user.profileImageUrl)).resizable().scaledToFill().frame(width:50,height: 50).clipped().cornerRadius(50).overlay(RoundedRectangle(cornerRadius: 50).stroke(Color(.label),lineWidth: 2))
                        
                            Text(user.email).foregroundColor(Color(.label))
                         
                        }
                        Spacer()
                    }.padding(.horizontal)
                    Divider().padding(.vertical)
    
                }
            }.navigationTitle(" New Message")
                .toolbar{
                    ToolbarItemGroup(placement: .navigationBarLeading){
                        Button{
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("cancel")
                        }
                    }
                }
        }
    }
}

#Preview {
    CreateNewMessageView(didSelectNewUser: {user in
        print(user.email)
    })
}
