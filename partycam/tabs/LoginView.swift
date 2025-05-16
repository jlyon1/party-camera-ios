import SwiftUI

struct LoginView: View {
    @FocusState private var isFocused: Bool // Track the focus state
    
    var body: some View {
        NavigationStack {
            OTPTextField(numberOfFields: 4)                
                .focused($isFocused) // Bind the focus state
                .onAppear {
                    // Focus the text field when the view appears
                    isFocused = true
                }
        }
    }
}
