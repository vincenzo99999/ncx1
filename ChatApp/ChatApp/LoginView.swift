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
    @State var email:String = ""
    @State var password:String = ""
    @State var isLoginMode = false
    @State var loginMessage: String = ""
    @State var shouldShowImagePicker=false
    @State var image : UIImage?
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
            
                 loginUser()
            
        }
        else{
                 createNewAccount()
            
            print("create new account")
        }
    }
    private func createNewAccount(){
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
                self.loginMessage="Failed to login as user\(err)"
                return
            }
            self.loginMessage="Successfully logged in as user:\(result?.user.uid ?? "")"
        }
        
    }
    
    private func persistImageToStorage(){
        let filename=UUID().uuidString
        guard let uid=FirebaseManager.shared.auth.currentUser?.uid
        else{return}
        guard let imageData=self.image?.jpegData(compressionQuality: 0.5)
        else {return}
        let ref = FirebaseManager.shared.storage.reference(withPath:uid)
        ref.putData(imageData, metadata: nil)
        {metadata,err in
            if let err=err{
                self.loginMessage="Failed to push image to Storage:\(err)"
                return
            }
        }
        ref.downloadURL{ url,err in
            if let _ = err {
                self.loginMessage="failed to retrieve downloadURL"
                return
            }
            self.loginMessage="successfully stored image with url:\(url?.absoluteString ?? "")"
            print(url?.absoluteString ?? "")
            guard let url=url else{return}
            self.storeUserInformation(imageProfileUrl:url)
        }
    }


        private func storeUserInformation(imageProfileUrl:URL?){
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{return}
            let userData=["email":self.email,"uid":uid,"profileImageUrl":imageProfileUrl?.absoluteString]
            FirebaseManager.shared.firestore.document(uid).setData(userData as [String : Any]){err in
                if let err=err{
                    print(err)
                    self.loginMessage="\(err)"
                    return
                }
              print(loginMessage)
            }
        }
    }


#Preview {
    LoginView()
}
