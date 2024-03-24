//
//  CreateNewMessageModel.swift
//  ChatApp
//
//  Created by Vincenzo Eboli on 24/03/24.
//

import Foundation
import SwiftUI

class CreateNewMessageViewModel:ObservableObject{
    @Published var users=[ChatUser]()
    @Published var errorMessage:String=""
    init(){
        fetchAllUsers()
    }
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection("users").getDocuments { documentSnapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch users: \(error)"
                return
            }
            documentSnapshot?.documents.forEach({
                snapshot in
                let data = snapshot.data()
                let user = ChatUser(data: data)
                if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                    self.users.append(.init(data: data))
                }
            })
            
            
        }
    }
}


