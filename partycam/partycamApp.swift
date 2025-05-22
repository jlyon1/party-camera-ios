//
//  partycamApp.swift
//  partycam
//
//  Created by Joey Lyon on 5/9/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins


let backendUrl = "https://party-camera-iota.vercel.app";

struct PresignedUpload: Decodable {
    let signedUrl: String
    let fileNameWithType: String
    let fileName: String
}

struct ImageAsset: Decodable, Identifiable {
    let id: String
    let size: String
    let width: Int
    let height: Int
    let url: String
}

struct ImageWithAssets: Decodable, Identifiable {
    let id: String
    let url: String
    let assets: [ImageAsset]
}

struct EventFeedItem: Decodable, Identifiable {
    var id: String
    let ownerId: String
    let ownerName: String
    let size: String
    let presignedUrl: String
}

struct EventFeed: Decodable {
    let id: Int
    let name: String
    let description: String
    let feedItems: [EventFeedItem]
}


struct EventImageAsset: Decodable, Identifiable {
    let id: String
    let size: String
    let width: Int
    let height: Int
    let url: String
    let presignedUrl: String
}

struct EventImage: Decodable, Identifiable {
    let id: String
    let url: String
    let uploadDate: String
    let assets: [EventImageAsset]
}

struct SessionData: Decodable, Identifiable {
    let username: String?
    let userId: String?
    
    var id: String {
        userId ?? UUID().uuidString // fallback if userId is nil
    }
    
}

class GalleryAndFeedDataModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var eventFeedsDict: [Int: EventFeed] = [:]
    @Published var userId: String?
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func fetchEvents() async throws {
        guard let url = URL(string: "\(backendUrl)/api/event/me") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            print("Response Status Code: \(httpResponse.statusCode)")
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON Response:\n\(jsonString)")
        }

        do {
            let decoded = try JSONDecoder().decode([Event].self, from: data)
            print("Successfully decoded \(decoded.count) event(s).")
            
            await MainActor.run {
                self.events = decoded
            }
        } catch {
            print("JSON Decoding error: \(error)")
            throw error
        }
    }
    
    func createEvent(name: String, description: String, startDate: String, endDate: String, blur: Bool) async throws {
        guard let url = URL(string: "\(backendUrl)/api/event/create") else {
            throw URLError(.badURL)
        }

        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Prepare JSON body
        let bodyDict: [String: String] = [
            "name": name,
            "description": description,
            "startDate": startDate,
            "endDate": endDate,
            "blur": blur ? "true" : "false"
        ]
        
        request.httpBody = try JSONEncoder().encode(bodyDict)
        
        print("\(request.httpBody?.base64EncodedString())")

        // Make the network call
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Response Status Code: \(httpResponse.statusCode)")
        }

        // Optional: Print the raw JSON response for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON Response:\n\(jsonString)")
        }

        // If you want to decode a response, add decoding logic here
        // For example, if server returns created Event:
         let createdEvent = try JSONDecoder().decode(Event.self, from: data)
        print("Created \(createdEvent.id)")
    }
    
    func fetchEventFeed(id: Int, overwrite: Bool = false) async throws {
        guard let url = URL(string: "\(backendUrl)/api/event/\(id)/feed") else {
            throw URLError(.badURL)
        }
        
        if self.eventFeedsDict[id] != nil {
            if !overwrite {
                print("Already there \(id), not overwriting")
                print("All keys: \(self.eventFeedsDict.keys)")
                return
            }
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            print("response Status Code: \(httpResponse.statusCode)")
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON Response:\n\(jsonString)")
        }

        do {
            let decoded = try JSONDecoder().decode(EventFeed.self, from: data)

            await MainActor.run {
                print("Got event feed for event \(id) has \(decoded.feedItems.count) items")
                self.eventFeedsDict[id] = decoded
            }
        } catch {
            print("JSON Decoding error: \(error)")
            throw error
        }
    }
    
    func fetchSession() async throws {
        guard let url = URL(string: "\(backendUrl)/api/session") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            print("response Status Code: \(httpResponse.statusCode)")
        }
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON Response:\n\(jsonString)")
        }
        
        do {
            let decoded = try JSONDecoder().decode(SessionData.self, from: data)

            await MainActor.run {
                print("Retrieved session data")
                self.userId = decoded.userId
            }
        } catch {
            print("JSON Decoding error: \(error)")
            throw error
        }
    }
}

@main
struct partycamApp: App {
    @StateObject var session = SessionManager()
    @StateObject var galleryAndFeedDataModel = GalleryAndFeedDataModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .environmentObject(galleryAndFeedDataModel)
                .onAppear {
                    session.checkSession { _ in
                        // Optional: react to session check completion if needed
                    }
                }
        }
    }
}
