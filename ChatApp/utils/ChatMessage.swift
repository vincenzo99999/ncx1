//
//  ChatMessage.swift
//  ChatApp
//
//  Created by Vincenzo Eboli on 26/03/24.
//

import Foundation
import Firebase
struct FirebaseConstants{
    static let fromId="fromId"
    static let toId="toId"
    static let text="text"
    static let email:String = "email"
    static let profileImageUrl:String = "profileImageUrl"
    static let timestamp = "timestamp"

}

struct ChatMessage:Identifiable{
    let fromId,toId,text:String
    let documentId:String
    var id : String{documentId}
    init(documentId:String,data:[String:Any]){
        self.documentId=documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
   
}

struct RecentMessage:Identifiable{
    let documentId:String
    let text,fromId,toId,email:String
    let timestamp:Firebase.Timestamp
    let profileImageUrl:String
    var id: String{documentId}
    init(documentId:String,data:[String:Any]){
        self.documentId=documentId
        self.email=data[FirebaseConstants.email] as? String ?? ""
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
        self.timestamp = data[FirebaseConstants.timestamp] as? Timestamp ?? Timestamp(date: Date())
        self.profileImageUrl=data[FirebaseConstants.profileImageUrl] as? String ?? ""
    }
}
