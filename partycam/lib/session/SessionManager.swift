//
//  SessionManager.swift
//  partycam
//
//  Created by Joey Lyon on 5/16/25.
//

import Foundation

class SessionManager: ObservableObject {
    @Published var isLoggedIn = false

    
    func checkSession(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(backendUrl)/api/session") else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil,
                      let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    self.isLoggedIn = false
                    completion(false)
                    return
                }
                self.isLoggedIn = true
                completion(true)
            }
        }.resume()
    }
    
    func updateLoginStatusBasedOnResponse(_ response: URLResponse?) {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        
        // Check if status code is 200 (or whatever your success code is)
        if httpResponse.statusCode == 200 {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }
}
