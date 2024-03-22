//
//  MainMessagesView.swift
//  ChatApp
//
//  Created by Vincenzo Eboli on 22/03/24.
//

import Foundation
import SwiftUI
struct MainMessagesView:View {
    @State var shouldShowLogOutOptions=false
    var body: some View {
        NavigationView{
            VStack{
                HStack{
                    Image(systemName: "person.fill").font(.system(size: 24,weight: .heavy));
                    VStack{
                        Text("Username").font(.system(size: 34,weight: .bold))
                        
                        HStack{
                            
                            Circle().foregroundColor(.green).frame(width:13,height: 14)
                            Text("online").foregroundColor(.gray)
                        }
                        
                    }
                    Spacer()
                    Button{
                        shouldShowLogOutOptions.toggle()
                    } label:{
                        Image(systemName: "gear").font(.system(size: 24)).foregroundColor(Color(.blue))
                    }
                }.padding().actionSheet(isPresented: $shouldShowLogOutOptions){
                    .init(title: Text("Settings"),message: Text("Default"),buttons: [
                        .destructive(Text("Sign Out"),action: {print("signed out")
                        }),
                        .cancel()
                    ])
                        
                }
                ScrollView{
                    ForEach(0..<15,id:\.self){num in
                        
                        HStack(spacing:16){
                            Image(systemName: "person.fill").font(.system(size:32)).overlay(RoundedRectangle(cornerRadius: 44).stroke(Color.black,lineWidth: 1))
                            VStack(alignment: .leading){
                                Text("username")
                                Text("Last text sent to the user").font(.system(size: 14)).foregroundColor(Color(.lightGray))
                            }
                            Spacer()
                          
                            Text("receiving time").font(.system(size:14,weight: .semibold))
                        }
                        Divider()
                    }
                }.padding(.horizontal)
            }
        }.navigationBarHidden(true)
            .overlay(
                Button{
                    Spacer()
                } label:{
                    HStack{
                        Spacer()
                        Text("+ New Messages").background(Color.blue)
                        Spacer()
                    }.foregroundColor(.white).padding(.vertical).background(Color.blue).padding(.horizontal).cornerRadius(50).shadow(radius: 20)
                }, alignment : .bottom).padding(.bottom)
    }
}
#Preview {
    MainMessagesView()
}
