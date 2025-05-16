//
//  RootView.swift
//  partycam
//
//  Created by Joey Lyon on 5/16/25.
//

import Foundation
import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        Group {
            if session.isLoggedIn {
                TabView(){
                    Create(backend: LiveBackendManager()).tabItem { Image(systemName: "plus") }
                    Gallery(backend: LiveBackendManager()).tabItem { Image(systemName: "camera") }
                    Settings(backend: LiveBackendManager()).tabItem { Image(systemName: "gear") }
                }
                
            } else {
                LoginView()
            }
        }
    }
}
