import Foundation
import SwiftUI
import Firebase


class ChatLogViewModel: ObservableObject {
    let chatUser: ChatUser?
    @Published var errorMessage: String = ""
    @Published var chatText: String = ""
    @Published var chatMessages=[ChatMessage]()
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
    }
    private func fetchMessages(){
        guard let fromId=FirebaseManager.shared.auth.currentUser?.uid else{return}
        guard let toId = chatUser?.uid else {return}
        FirebaseManager.shared.firestore.collection("messages").document(fromId).collection(toId).order(by: "timestamp").addSnapshotListener {querySnapshot, error in
            if let error = error {
                self.errorMessage="Failed to listen for messages:\(error) "
                print(error)
                return
            }
            querySnapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let data = change.document.data()
                    self.chatMessages.append(.init(documentId:change.document.documentID, data: data))
                }
            })
            }
        }
    func handleSend(){
        
        guard let fromId=FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        guard let toId=chatUser?.uid else {return}
        let document = FirebaseManager.shared.firestore.collection("messages")
            .document(fromId).collection(toId).document()
        let messageData = [FirebaseConstants.fromId:fromId,FirebaseConstants.toId:toId,FirebaseConstants.text:
                            self.chatText,"timestamp":Timestamp()] as [String:Any]
        document.setData(messageData){error in
            if let error=error{
                self.errorMessage="failed to save in firestore \(error)"
                return
            }
            
        }
        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
            .document(toId).collection(fromId).document()
        recipientMessageDocument.setData(messageData){error in
            if let error=error{
                self.errorMessage="failed to save message into firestore: \(error)"
                return
            }
        }
        self.chatText=""
    }
    
}




