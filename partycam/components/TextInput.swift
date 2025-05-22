//
//  TextInput.swift
//  partycam
//
//  Created by Joey Lyon on 5/18/25.
//

import SwiftUI

struct PartyTextInput: View {
    
    @Binding var text: String
    
    var placeholder: String
    
    var body: some View {
        TextField(placeholder, text: $text).textFieldStyle(.roundedBorder)
    }
    
}

#Preview {
    @Previewable @State var txt = "hello world"
    PartyTextInput(text: $txt, placeholder: "placeholder")
}
