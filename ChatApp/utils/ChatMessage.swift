//
//  ChatMessage.swift
//  ChatApp
//
//  Created by Vincenzo Eboli on 26/03/24.
//

import Foundation
struct FirebaseConstants{
    static let fromId="fromId"
    static let toId="toId"
    static let text="text"
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
