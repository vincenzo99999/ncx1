//
//  MainMessagesView.swift
//  ChatApp
//
//  Created by Vincenzo Eboli on 22/03/24.
//

import SwiftUI
import SDWebImageSwiftUI
class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser:ChatUser?
    init() {
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not load Firebase"
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user", error)
                self.errorMessage = "Failed to fetch current user \(error)"
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found for current user"
                return
            }
            
            guard let uid = data["uid"] as? String,
                  let email = data["email"] as? String,
                  let profileImageUrl = data["profileImageUrl"] as? String else {
                self.errorMessage = "Missing or invalid data keys"
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                let chatUser = ChatUser(uid: uid, email: email, profileImageUrl: profileImageUrl)
                self?.chatUser = chatUser
            }
        }
    }
}

struct MainMessagesView: View {
    @State private var shouldShowLogOutOptions = false
    @State private var vm = MainMessagesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
               
                
                HStack {
                    if let chatUser = vm.chatUser{
                        Text("Current User email : \(vm.chatUser?.email ?? "")")
                        WebImage(url: URL(string:vm.chatUser?.profileImageUrl ?? "")).resizable().frame(width: 50,height: 50).clipped(antialiased: true)
                    }
                        else{
                            Text(vm.errorMessage.isEmpty ? "Loading" : vm.errorMessage)
                        }
               
                    VStack {
                        Text("Username")
                            .font(.system(size: 34, weight: .bold))
                        
                        HStack {
                            Circle()
                                .foregroundColor(.green)
                                .frame(width: 13, height: 14)
                            Text("online")
                                .foregroundColor(.gray)
                        }
                    
                    }
                    Spacer()
                    Button {
                        shouldShowLogOutOptions.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .font(.system(size: 24))
                            .foregroundColor(Color(.blue))
                    }







                }
                .padding()
                .actionSheet(isPresented: $shouldShowLogOutOptions) {
                    ActionSheet(
                        title: Text("Settings"),
                        message: Text("Default"),
                        buttons: [
                            .destructive(Text("Sign Out")) {
                                print("signed out")
                            },
                            .cancel()
                        ]
                    )
                }
                
                ScrollView {
                    ForEach(0..<15, id: \.self) { num in
                        HStack(spacing: 16) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color.black, lineWidth: 1))
                            VStack(alignment: .leading) {
                                Text("username")
                                Text("Last text sent to the user")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.lightGray))
                            }
                            Spacer()
                            Text("receiving time")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Divider()
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .overlay(
            Button {
                // Handle action
            } label: {
                HStack {
                    Spacer()
                    Text("+ New Messages")
                        .background(Color.blue)
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical)
                .background(Color.blue)
                .padding(.horizontal)
                .cornerRadius(50)
                .shadow(radius: 20)
            },
            alignment: .bottom
        )
        .padding(.bottom)
    }
}

#Preview {
    MainMessagesView().preferredColorScheme(.dark)
}
