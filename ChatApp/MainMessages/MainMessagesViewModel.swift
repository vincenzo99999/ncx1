//
//  MainMessagesViewModel.swift
//  ChatApp
//
//  Created by Vincenzo Eboli on 24/03/24.
//
import SwiftUI
import Foundation

class MainMessageViewModel:ObservableObject{
    @Published var errorMessage:String = ""
    @Published var chatUser:ChatUser?
    @Published var isUserLoggedOut=true
    @Published var recentMessages = [RecentMessage]()
    func handleSignOut(){
        isUserLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
        
    }
    
    init(){
        DispatchQueue.main.async{
            self.isUserLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
            print(self.isUserLoggedOut)
        }
        self.fetchCurrentUser()
        self.fetchRecentMessages()
    }
    private func fetchRecentMessages(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{return}
        FirebaseManager.shared.firestore.collection("recent_messages").document(uid).collection("messages").order(by: "timestamp").addSnapshotListener { querySnapshot, error in
            if let error=error{
                self.errorMessage="failed to listen to changes:\(error)"
                print(error)
                return
            }
            querySnapshot?.documentChanges.forEach({change in
                
                    let docId=change.document.documentID
                if let index = self.recentMessages.firstIndex(where:{rm in
                    return rm.documentId==docId
                }) {
                    self.recentMessages.remove(at: index)
                }
                    self.recentMessages.insert(.init(documentId:docId,data: change.document.data()),at: 0)
                
            })
        }
    }
    
     func fetchCurrentUser(){
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
            self.chatUser = .init(data: data)
        }
    }
   
}
