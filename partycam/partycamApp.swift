//
//  partycamApp.swift
//  partycam
//
//  Created by Joey Lyon on 5/9/25.
//

import SwiftUI

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

class GalleryAndFeedDataModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var eventFeedsDict: [Int: EventFeed] = [:]
    
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
