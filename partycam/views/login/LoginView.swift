import SwiftUI

struct LoginView: View {
    @State private var code: String = ""
    @State private var isLoggingIn: Bool = false
    @State private var loginResult: String?
    @EnvironmentObject var session: SessionManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter 6-digit code")
                .font(.headline)

            TextField("000000", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .onChange(of: code) { newValue in
                    code = newValue.filter { $0.isNumber }.prefix(6).description
                }
                .multilineTextAlignment(.center)
                .frame(width: 150)
                .textFieldStyle(.roundedBorder) // System style

            Button(action: logIn) {
                if isLoggingIn {
                    ProgressView()
                } else {
                    Text("Log In")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(code.count != 6)
            
            Text(session.isLoggedIn.description)

            if let result = loginResult {
                Text(result)
                    .foregroundColor(.green)
                    .padding(.top, 10)
            }
        }
        .padding()
    }


    func logIn() {
        guard let url = URL(string: "\(backendUrl)/api/login/code") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["code": code])
        
        isLoggingIn = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoggingIn = false
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status code: \(httpResponse.statusCode)")
                    print("Headers: \(httpResponse.allHeaderFields)")
                }
                
                if let data = data,
                   let bodyString = String(data: data, encoding: .utf8) {
                    print("Response body: \(bodyString)")
                }
                
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    session.isLoggedIn = true
                } else {
                    session.isLoggedIn = false
                }
            }
        }.resume()
    }
}

#Preview {
    LoginView()
}
