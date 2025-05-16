//
//  partycamApp.swift
//  partycam
//
//  Created by Joey Lyon on 5/9/25.
//

import SwiftUI

let backendUrl = "https://party-camera-iota.vercel.app";

@main
struct partycamApp: App {
    @StateObject var session = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .onAppear {
                    session.checkSession { _ in
                        // Optional: react to session check completion if needed
                    }
                }
        }
    }
}
