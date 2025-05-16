//
//  partycamApp.swift
//  partycam
//
//  Created by Joey Lyon on 5/9/25.
//

import SwiftUI

@main
struct partycamApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView(text: "hi")
                    .tabItem {
                        Label("Journal", systemImage: "book")
                    }
                ContentView(text: "Settings")
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}
