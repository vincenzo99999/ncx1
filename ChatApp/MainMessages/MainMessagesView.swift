import SwiftUI
import SDWebImageSwiftUI
class MainMessagesViewModel: ObservableObject {
   @Published var errorMessage = ""
    @Published var chatUser:ChatUser?
    init() {
        fetchCurrentUser()
    }
    
    private func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
                self.errorMessage="could not load firebase"
                return
        }
        self.errorMessage="\(uid)"
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("failed to fetch current user", error)
                self.errorMessage = "failed to fetch current user \(error)"
                return
            }
            guard let data = snapshot?.data() else { return}
            print(data)
            self.errorMessage="\(data.description)"
            
            let uid=["uid"] as? String
            let email=["email"] as? String
            let profileImageUrl=["profileImageUrl"] as? String
            let chatUser=ChatUser(uid: uid ?? "", email: email ?? "", profileImageUrl: profileImageUrl ?? "")
            print("\(String(describing: profileImageUrl))\n")
            print("\(String(describing: email))\n")

            
        }
    }
}

struct MainMessagesView: View {
    @State private var shouldShowLogOutOptions = false
    @ObservedObject private var vm = MainMessagesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                
                Text("Current User email : \(vm.chatUser?.email ?? "")")
                
                HStack {
                    WebImage(url: URL(string:vm.chatUser?.profileImageUrl ?? "")).resizable().frame(width: 50,height: 50).clipped(antialiased: true)
                    VStack {
                        Text("Username")
                            .font(.system(size: 34, weight: .bold))
                        
                        HStack {
                            Circle()
                                .foregroundColor(.green)
                                .frame(width: 13, height: 14)
                            Text("online")
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    Button {
                        shouldShowLogOutOptions.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .font(.system(size: 24))
                            .foregroundColor(Color(.blue))
                    }
                }
                .padding()
                .actionSheet(isPresented: $shouldShowLogOutOptions) {
                    ActionSheet(
                        title: Text("Settings"),
                        message: Text("Default"),
                        buttons: [
                            .destructive(Text("Sign Out")) {
                                print("signed out")
                            },
                            .cancel()
                        ]
                    )
                }
                
                ScrollView {
                    ForEach(0..<15, id: \.self) { num in
                        HStack(spacing: 16) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color.black, lineWidth: 1))
                            VStack(alignment: .leading) {
                                Text("username")
                                Text("Last text sent to the user")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.lightGray))
                            }
                            Spacer()
                            Text("receiving time")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Divider()
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .overlay(
            Button {
                // Handle action
            } label: {
                HStack {
                    Spacer()
                    Text("+ New Messages")
                        .background(Color.blue)
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical)
                .background(Color.blue)
                .padding(.horizontal)
                .cornerRadius(50)
                .shadow(radius: 20)
            },
            alignment: .bottom
        )
        .padding(.bottom)
    }
}

#Preview {
    MainMessagesView().preferredColorScheme(.dark)
}
