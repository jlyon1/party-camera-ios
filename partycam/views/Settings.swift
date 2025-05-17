//
//  Settings.swift
//  partycam
//
//  Created by Joey Lyon on 5/16/25.
//

import Foundation
import SwiftUI

struct Settings: View {
    let backend: BackendManager
    @State private var isLoggingOut: Bool = false
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Button(action: logOut) {
                        if isLoggingOut {
                            ProgressView()
                        } else {
                            Text("Log Out")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    func logOut(){
        isLoggingOut = true
        session.logout()
        isLoggingOut = false
        
    }
}
