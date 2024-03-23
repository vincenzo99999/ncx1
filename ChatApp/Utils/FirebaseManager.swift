//
//  FirebaseManager.swift
//  ChatApp
//
//  Created by Vincenzo Eboli on 22/03/24.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseMessaging
import FirebaseInAppMessagingSwift

class FirebaseManager:NSObject{
    let auth:Auth
    let storage:Storage
    let firestore:Firestore
    static let shared=FirebaseManager()
    override init(){
        FirebaseApp.configure()
        self.auth=Auth.auth()
        self.storage=Storage.storage()
        self.firestore=Firestore.firestore()
        super.init()
    }
}
