//
//  BackendManager.swift
//  partycam
//
//  Created by Joey Lyon on 5/16/25.
//

import Foundation   

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

struct Event: Decodable, Identifiable, Hashable, Equatable {
    // TODO: These are incomplete
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.start == rhs.start &&
        lhs.end == rhs.end &&
        lhs.ownerId == rhs.ownerId &&
        lhs.image == rhs.image &&
        lhs.eventImage?.id == rhs.eventImage?.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(start)
        hasher.combine(end)
        hasher.combine(ownerId)
        hasher.combine(image)
    }
    
    let id: Int
    let name: String
    let description: String
    let start: String
    let end: String?
    let ownerId: String?
    let image: String? // it's null in the JSON
    let eventImage: EventImage?
    let eventMembers: [EventMember]?

    var startTimeFormatted: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: start) ?? ISO8601DateFormatter().date(from: start) else {
            return start
        }

        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"

        if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = "ha"
            return "\(dateFormatter.string(from: date)) Today"
        } else if calendar.isDateInTomorrow(date) {
            dateFormatter.dateFormat = "ha"
            return "\(dateFormatter.string(from: date)) Tomorrow"
        } else {
            dateFormatter.dateFormat = "MMM d, ha"
            return dateFormatter.string(from: date)
        }
    }

    var imageURL: URL {
        if let asset = eventImage?.assets.first(where: { $0.size == "thumbnail" }),
           let url = URL(string: asset.url) {
            return url
        } else {
            return URL(string: "https://placekitten.com/200/200")!
        }
    }
}

struct EventMember: Decodable {
    let user: User
}

struct User: Decodable {
    let name: String
}

protocol BackendManager {
    func fetchEvents() async throws -> [Event]
    func fetchEvent(id: Int) async throws -> Event
    func fetchEventFeed(id: Int) async throws -> EventFeed
    func fetchImageAssets(id: String) async throws -> ImageWithAssets
}

class LiveBackendManager: BackendManager {
    func fetchImageAssets(id: String) async throws -> ImageWithAssets {
        guard let url = URL(string: "\(backendUrl)/api/image/\(id)/assets") else{
            throw URLError(.badURL)
        }
        
        print("Grabbing image assets for id \(id)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("fetchImageAssets \(id): Status Code \(httpResponse.statusCode)")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("fetchImageAssets \(id): Raw JSON String \(jsonString)")
        }
        
        do {
            let decoded = try JSONDecoder().decode(ImageWithAssets.self, from: data)
            print("✅ Successfully decoded \(decoded.assets) assets(s).")
            return decoded
        } catch {
            print("🧨 JSON Decoding error: \(error)")
            throw error
        }
    }
    
    func fetchEvents() async throws -> [Event] {
        guard let url = URL(string: "\(backendUrl)/api/event/me") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            print("📡 Response Status Code: \(httpResponse.statusCode)")
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Raw JSON Response:\n\(jsonString)")
        }

        do {
            let decoded = try JSONDecoder().decode([Event].self, from: data)
            print("✅ Successfully decoded \(decoded.count) event(s).")
            return decoded
        } catch {
            print("🧨 JSON Decoding error: \(error)")
            throw error
        }
    }

    func fetchEvent(id: Int) async throws -> Event {
        guard let url = URL(string: "\(backendUrl)/api/event/\(id)") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            print("📡 Response Status Code: \(httpResponse.statusCode)")
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Raw JSON Response:\n\(jsonString)")
        }

        do {
            let decoded = try JSONDecoder().decode(Event.self, from: data)
            print("✅ Successfully decoded event with id \(id).")
            return decoded
        } catch {
            print("🧨 JSON Decoding error: \(error)")
            throw error
        }
    }
    
    func fetchEventFeed(id: Int) async throws -> EventFeed {
        guard let url = URL(string: "\(backendUrl)/api/event/\(id)/feed") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            print("📡 Response Status Code: \(httpResponse.statusCode)")
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Raw JSON Response:\n\(jsonString)")
        }

        do {
            let decoded = try JSONDecoder().decode(EventFeed.self, from: data)
            print("✅ Successfully decoded event feed for event \(id).")
            return decoded
        } catch {
            print("🧨 JSON Decoding error: \(error)")
            throw error
        }
    }
}
