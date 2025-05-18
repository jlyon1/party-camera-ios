//
//  Create.swift
//  partycam
//
//  Created by Joey Lyon on 5/16/25.
//

import Foundation
import SwiftUI

struct Create: View {
    let backend: BackendManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("CREATE EVENT")
                }
            }
            .navigationTitle("Create Event")
        }
    }
}

#Preview {
    Create(backend: LiveBackendManager())
}
