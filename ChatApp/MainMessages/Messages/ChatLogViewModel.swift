import Foundation
import SwiftUI
import Firebase

class ChatLogViewModel: ObservableObject {
    let chatUser: ChatUser?
    @Published var errorMessage: String = ""
    @Published var chatText: String = ""

    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
    }
    
    func handleSend() {
        print(chatText)
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Couldn't load current user"
            return
        }
        print(fromId)
        
        guard let toId = chatUser?.uid else {
            self.errorMessage = "Couldn't retrieve the user ID"
            return
        }
        print(toId)

        let collectionPath = "messages/\(fromId)_to_\(toId)"

        let documentRef = FirebaseManager.shared.firestore.collection(collectionPath).document()

        let messageData: [String: Any] = [
            "fromId": fromId,
            "toId": toId,
            "text": self.chatText,
            "timestamp": Timestamp()
        ]

        documentRef.setData(messageData) { error in
            if let error = error {
                print("Error saving message to Firestore: \(error)")
                self.errorMessage = "Failed to save message into Firestore: \(error.localizedDescription)"
            } else {
                print("Message saved successfully")
                // Optionally, clear chat text after sending
                self.chatText = ""
            }
        }
    }



}
