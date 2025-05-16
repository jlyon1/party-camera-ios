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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("YOUR PROFILE")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
