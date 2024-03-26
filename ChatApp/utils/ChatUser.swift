//
//  ChatUser.swift
//  ChatApp
//
//  Created by Vincenzo Eboli on 23/03/24.
//


import Foundation
struct ChatUser:Identifiable{
    var id=UUID()
    let uid,email,profileImageUrl : String
    init(data:[String:Any]){
        self.uid=data["uid"] as? String ?? ""
        print(self.uid)
        self.email=data["email"] as? String ?? ""
        self.profileImageUrl=data["profileImageUrl"] as? String ?? ""
    }
}
