import Foundation
import SwiftUI
import Firebase


class ChatLogViewModel: ObservableObject {
    let chatUser: ChatUser?
    @Published var errorMessage: String = ""
    @Published var chatText: String = ""
    @Published var chatMessages=[ChatMessage]()
    @Published var count:Int=0
    
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
        
        
        self.count+=1
    
    }
    
    func handleSend(){
        if !(self.chatText.isEmpty){
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
            self.persistRecentMessage()
            self.chatText=""
            DispatchQueue.main.async{
                self.count+=1
            }
        }else{
            self.errorMessage="cannot send an empty text"
            print("cannot send an empty text")
        }
    }
    private func persistRecentMessage(){
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else {return}
        guard let toId = self.chatUser?.uid else{return}
        let document = FirebaseManager.shared.firestore.collection("recent_messages").document(fromId).collection("messages").document(toId)
        let data:[String:Any]=[
            FirebaseConstants.timestamp:Timestamp(),
            FirebaseConstants.text:self.chatText,
            FirebaseConstants.fromId:fromId,
            FirebaseConstants.toId:toId,
            FirebaseConstants.profileImageUrl:chatUser?.profileImageUrl ?? "" ,
            FirebaseConstants.email:chatUser?.email ?? ""
        ]
        let recipientDocument = FirebaseManager.shared.firestore.collection("recent_messages").document(toId).collection("messages").document(fromId)
        
        let recipientData: [String: Any] = [
            FirebaseConstants.timestamp:Timestamp(),
            FirebaseConstants.text:self.chatText,
            FirebaseConstants.fromId:toId,
            FirebaseConstants.toId:fromId,
            FirebaseConstants.profileImageUrl:chatUser?.profileImageUrl ?? "" ,
            FirebaseConstants.email:chatUser?.email ?? ""
        ]
        
        recipientDocument.setData(recipientData) { error in
            if let error = error {
                self.errorMessage = "failed to save recipient data: \(error)"
                return
            }
        }

         document.setData(data){error in
            if let error = error {
                self.errorMessage = "failed to save recent message \(error)"
                return
            }
        }
    }
    
}
