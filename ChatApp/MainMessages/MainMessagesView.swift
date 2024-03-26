    //
    //  MainMessagesView.swift
    //  ChatApp
    //
    //  Created by Vincenzo Eboli on 22/03/24.
    //

    import SwiftUI
    import Foundation
    import SDWebImageSwiftUI


    struct MainMessagesView:View {
        @ObservedObject var vm=MainMessageViewModel()
        @State var shouldShowLogOutOptions=false
        @State var shouldShowNewMessageScreen=false
        @State var shouldNavigateToChatLogView=false
        @State var chatUser:ChatUser?

        private var customNavBar:some View{
            HStack{
                WebImage(url:URL(string: vm.chatUser?.profileImageUrl ?? "")).resizable().scaledToFill().frame(width:50,height:50).clipped().cornerRadius(50).overlay(RoundedRectangle(cornerRadius: 45)
                    .stroke(Color(.label),lineWidth: 1).padding(.horizontal,16)
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
                        self.vm.fetchCurrentUser()
                    })
                }
            }
        }
        var body: some View {
            NavigationView{
                
                VStack{
                    customNavBar
                    messagesView
                   
                    NavigationLink("",isActive: $shouldNavigateToChatLogView){
                        ChatLogView(chatUser: self.chatUser)
                    }
                        
            }.overlay(
               newMessageButton,alignment: .bottom)
            }.navigationTitle("main MessagesView")
        }
        private var messagesView:some View{
            ScrollView{
                
                    ForEach(0..<10,id:\.self){num in
                        VStack{
                            NavigationLink {
                                ChatLogView(chatUser: self.chatUser)
                            } label: {
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
                            }

                          
                            Divider()
                                .padding(.vertical,10)
                        }.padding(.horizontal)
                        
                    }
            }
        }
        private var newMessageButton:some View{
            Button{
                shouldShowNewMessageScreen.toggle()
            } label: {
                HStack{
                Spacer()
                Text("+ New Message")
                        .font(.system(size:16,weight: .bold))
                    
                Spacer()
                }.background(Color.blue).cornerRadius(32).padding(.vertical).foregroundColor(.white).padding(.horizontal)
                    .shadow(radius: 15)
            }.fullScreenCover(isPresented:$shouldShowNewMessageScreen){
                CreateNewMessageView (didSelectNewUser:{ user in
                    print(user.email)
                    self.shouldNavigateToChatLogView.toggle()
                    self.chatUser=user
                })
            }
        }
    }

    #Preview {
        MainMessagesView()
    }
