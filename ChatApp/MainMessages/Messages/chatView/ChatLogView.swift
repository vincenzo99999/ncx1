import SwiftUI

struct ChatLogView: View {
    let chatUser: ChatUser?
    @State var isChatFocused = ""
    @ObservedObject var vm: ChatLogViewModel
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    
    var body: some View {
        VStack {
            Text(vm.errorMessage)
            messagesView
            Spacer()
            chatBottomBar
        }
        .navigationTitle(chatUser?.email ?? "").navigationBarTitleDisplayMode(.inline)
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle").font(.system(size: 24)).foregroundColor(Color(.darkGray))
            // use a textEditor instead
            TextField("Message", text: $vm.chatText).foregroundColor(.black)
            Button(action: {
            
                vm.handleSend()
            }) {
                Text("Send").foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(5)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    ForEach(vm.chatMessages) { message in
                        MessageView(message: message)
                            .id(message.documentId) // Use the message ID as a unique identifier
                    }
                }
                .background(Color.white)
                .onAppear {
                    scrollToBottom(scrollViewProxy: scrollViewProxy)
                }
                .onChange(of: vm.chatMessages.count) { _ in
                    scrollToBottom(scrollViewProxy: scrollViewProxy)
                }
            }
        }
    }
    
    private func scrollToBottom(scrollViewProxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            if let lastIndex = vm.chatMessages.last?.documentId {
                withAnimation(.easeOut(duration: 0.5)) {
                    scrollViewProxy.scrollTo(lastIndex, anchor: .bottom)
                }
            }
        }
    }
}

#Preview {
    NavigationView{
        ChatLogView(chatUser: .init(data: ["uid":"HHD5PiaPdfZ3IMZUcVRRg1RPghB2","email":"vincenzo5@gmail.com"])).preferredColorScheme(.light)
    }
}
