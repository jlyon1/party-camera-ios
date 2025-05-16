//
//  ContentView.swift
//  partycam
//
//  Created by Joey Lyon on 5/9/25.
//

import SwiftUI

struct ContentView: View {
    let text: String
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(text)
        }
        .padding()
    }
}

#Preview {
    ContentView(text: "hello")
}
