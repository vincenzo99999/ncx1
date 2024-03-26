//
//  ContentView.swift
//  ChatApp
//
//  Created by Vincenzo Eboli on 21/03/24.
//
import UIKit
import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore


struct LoginView: View {
    let didCompleteLoginProcess:()->()
    @State private var email:String = ""
    @State private var password:String = ""
    @State private var isLoginMode = false
    @State private var loginMessage: String = ""
    @State private var shouldShowImagePicker=false
    @State private var image : UIImage?
    var body: some View {
        VStack(spacing:12){
            NavigationView{
                ScrollView{
                    Picker(selection: $isLoginMode,  label:Text("Picker here")) { Text("Login").tag(true)
                        Text("Create Account").tag(false)
                    }.pickerStyle(SegmentedPickerStyle()).padding()
                    if !isLoginMode{
                        Button{
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack{
                                
                                if let image=self.image{
                                    Image(uiImage: image).resizable()
                                        .frame(width:64,height:54).scaledToFill().cornerRadius(64, antialiased: true)
                                }
                                else{
                                    Image(systemName: "person.fill").font(.system(size: 64)).padding()
                                }
                            }
                        }.overlay(RoundedRectangle(cornerRadius:64).stroke(Color.black,lineWidth: 3.0))
                    }
                    Group{
                        TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.none).background(Color(.white)).padding(12).font(.system(size: 14,weight: .semibold))
                        SecureField("Password",text: $password).background(Color(.white)).padding(20).font(.system(size: 14,weight: .semibold))
                    }
                    Button{
                        handleAction()
                        
                    } label: {
                        HStack(alignment: .top){
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account").foregroundColor(.white).padding(.vertical,20).font(.system(size: 14,weight: .semibold))
                            Spacer()
                        }.background(Color.blue).foregroundColor(.white).padding(.vertical,10)
                    }
                    Text(loginMessage)
                }
                
            }.navigationTitle(isLoginMode ? "Login" :  "Create Account")
                .padding().background(Color(.init(
                    gray:0,alpha:0.05)))
        }.navigationViewStyle(StackNavigationViewStyle()).fullScreenCover(isPresented:$shouldShowImagePicker,onDismiss:nil){
            ImagePicker(image:$image)
        }
    }
    private func handleAction(){
        if isLoginMode{
            print("login with existing creadentials on firebase")
            Task{
                 loginUser()
            }
        }
        else{
            Task{
                 createNewAccount()
            }
            print("create new account")
        }
    }
    private func createNewAccount(){
        if self.image==nil{
            self.loginMessage="you must select a profile picture"
            return
        }
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password){result,error in
            if let err = error{
                self.loginMessage="Failed to create user\(err)"
                return
            }
            self.loginMessage="Successfully created user:\(result?.user.uid ?? "")"
        
            self.persistImageToStorage()
            
        }
        
    }
    
    private func loginUser(){
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password){result,error in
            if let err = error{
                self.loginMessage="Failed to create user\(err)"
                return
            }
            self.loginMessage="Successfully logged in as user:\(result?.user.uid ?? "")"
            self.didCompleteLoginProcess()
        }
        
    }
    
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.loginMessage = "Failed to retrieve user UID"
            return
        }
        print(uid)
        
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {
            self.loginMessage = "Failed to convert image to data"
            return
        }
        
        let storageRef = FirebaseManager.shared.storage.reference().child("profile_images").child(uid).child(UUID().uuidString + ".jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                if let error = error {
                    self.loginMessage = "Failed to upload image to Storage: \(error.localizedDescription)"
                } else {
                    self.loginMessage = "Failed to upload image to Storage"
                }
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    self.loginMessage = "Failed to retrieve download URL: \(error.localizedDescription)"
                    return
                }
                
                guard let downloadURL = url else {
                    self.loginMessage = "Download URL is nil"
                    return
                }
                
                self.loginMessage = "Image uploaded successfully. URL: \(downloadURL)"
                
                
                self.storeUserInformation(imageProfileUrl: downloadURL)
            }
            
        }
    }


    private func storeUserInformation(imageProfileUrl: URL?) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Current user UID is nil")
            self.loginMessage = "Current user UID is nil"
            return
        }
        
        let userRef = FirebaseManager.shared.firestore.collection("users").document(uid)
        
        let userData: [String: Any] = [
            "email": self.email,
            "profileImageUrl": imageProfileUrl?.absoluteString ?? "",
            "uid":uid
        ]
        
        userRef.setData(userData) { error in
            if let error = error {
                print("Error storing user information: \(error.localizedDescription)")
                self.loginMessage = "Error storing user information: \(error.localizedDescription)"
            } else {
                print("User information stored successfully")
                self.loginMessage = "User information stored successfully"
            }
        }
        self.didCompleteLoginProcess()
    }

    }


#Preview {
    LoginView(didCompleteLoginProcess: {
        
    })
}
