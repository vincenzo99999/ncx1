//
//  ChatAppApp.swift
//  ChatApp
//
//  Created by Vincenzo Eboli on 21/03/24.
//

import SwiftUI

@main
struct ChatAppApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView()
            MainMessagesView()
        }
    }
}
