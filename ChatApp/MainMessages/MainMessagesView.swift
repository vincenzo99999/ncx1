//
//  MainMessagesView.swift
//  ChatApp
//
//  Created by Vincenzo Eboli on 22/03/24.
//

import SwiftUI
import Foundation
import SDWebImageSwiftUI
class MainMessageViewModel:ObservableObject{
    @Published var errorMessage:String = ""
    @Published var chatUser:ChatUser?
    
    init(){
        DispatchQueue.main.async{
            self.isUserLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
            fetchCurrentUser()
            
    }
    
    private func fetchCurrentUser(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{
            self.errorMessage="Couldn't find to firebase uid"
            return}
        self.errorMessage="\(uid)"
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument{snapshot,error in
            if let error=error{
                print("failed to fetch user:",error)
                self.errorMessage="failed to fetch user : \(error)"
                return
            }
            guard let data=snapshot?.data() else{
                self.errorMessage="no data found for the current user"
                return}
            print(data)
            self.errorMessage="Data:\(data.description)"
            let uid=data["uid"] as? String ?? ""
            print("\(uid)")
            let email = data["email"] as? String ?? ""
            print("\(email)")
            let profileImageUrl = data["profileImageUrl"] as? String ?? ""
            print("\(profileImageUrl)")
            self.chatUser=ChatUser(uid:uid,email: email.replacingOccurrences(of: "@gmail.com", with: ""),profileImageUrl: profileImageUrl)
        }
    }
    @Published var isUserLoggedOut=false
    func handleSignOut(){
        isUserLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
}

struct MainMessagesView:View {
    @ObservedObject var vm=MainMessageViewModel()
    @State var shouldShowLogOutOptions=false
    
    private var customNavBar:some View{
        HStack{
            WebImage(url:URL(string: vm.chatUser?.profileImageUrl ?? "")).resizable().scaledToFill().frame(width:50,height:50).clipped().cornerRadius(50).overlay(RoundedRectangle(cornerRadius: 45)
                .stroke(Color(.label),lineWidth: 1)
            )
            VStack(alignment:.leading,spacing: 4){
                Text("\(vm.chatUser?.email ?? "")").font(.system(size:24,weight: .bold)).foregroundColor(Color(.label))
                HStack{
                    Circle().foregroundColor(.green).frame(width:14,height:14)
                    
                    Text("online").font(.system(size:14)).foregroundColor(Color(.lightGray))
                }
            }
           
            Spacer()
            Button{
                shouldShowLogOutOptions.toggle()
            }label: {
                Image(systemName: "gear").font(.system(size: 24,weight: .bold)).foregroundColor(Color(.label))
            } .padding().actionSheet(isPresented:$shouldShowLogOutOptions){
                .init(title: Text("Settings"),message: Text("What do you want to do"),buttons:[
                    .destructive(Text("Sign out"),action:{
                        print("Handle Sign out")
                        vm.handleSignOut()
                    }),
                    .cancel()
                ])
            }
            .fullScreenCover(isPresented: $vm.isUserLoggedOut, onDismiss: nil){
                LoginView(didCompleteLoginProcess: {
                    self.vm.isUserLoggedOut = false
                })
            }
        }
    }
    var body: some View {
        NavigationView{
            
            VStack{
                customNavBar
                messagesView
               
                    
        }.overlay(
           newMessageButton,alignment: .bottom)
        }.navigationTitle("main MessagesView")
    }
    private var messagesView:some View{
        ScrollView{
            
                ForEach(0..<10,id:\.self){num in
                    VStack{
                        HStack(spacing:16){
                            Image(systemName: "person.fill")
                                .font(.system(size: 32)).padding().overlay(RoundedRectangle(cornerRadius: 45)
                                    .stroke(Color(.label),lineWidth: 1)
                                )
                            VStack(alignment:.leading){
                                Text("username").font(.system(size:14,weight:.bold)).foregroundColor(Color(.label))
                                Text("message sent to user").font(.system(size: 14,weight:.light)).foregroundColor(Color(.lightGray))
                            }
                            Spacer()
                            Text("22d").font(.system(size: 14,weight: .semibold))
                        }
                        Divider()
                            .padding(.vertical,10)
                    }.padding(.horizontal)
                    
                }
        }
    }
    private var newMessageButton:some View{
        Button{
            
        } label: {
            HStack{
            Spacer()
            Text("+ New Message")
                    .font(.system(size:16,weight: .bold))
                
            Spacer()
            }.background(Color.blue).cornerRadius(32).padding(.vertical).foregroundColor(.white).padding(.horizontal)
                .shadow(radius: 15)
        }
    }
}

#Preview {
    MainMessagesView().preferredColorScheme(.dark)
}
