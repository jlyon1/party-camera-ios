//
//  BackendManager.swift
//  partycam
//
//  Created by Joey Lyon on 5/16/25.
//

import Foundation



struct Event: Decodable, Identifiable, Hashable, Equatable {
    
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
    
    var endTimeFormatted: String {
        guard let endString = end else {
            return "Ongoing"
        }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let endDate = isoFormatter.date(from: endString) ?? ISO8601DateFormatter().date(from: endString) else {
            return endString
        }
        
        let now = Date()
        
        // If endDate is in the past or now, say so
        if endDate <= now {
            return "Ended"
        }
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: now, to: endDate)
        
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        
        var parts = [String]()
        if hours > 0 {
            parts.append("\(hours)h")
        }
        if minutes > 0 {
            parts.append("\(minutes)m")
        }
        
        let timeString = parts.joined(separator: " ")
        
        return "\(timeString)"
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
    func fetchPresignedUpload(contentType: String, eventId: Int) async throws -> PresignedUpload
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
    
    func fetchPresignedUpload(contentType: String, eventId: Int) async throws -> PresignedUpload {
        var components = URLComponents(string: "\(backendUrl)/api/presigned")!
        components.queryItems = [
            URLQueryItem(name: "contentType", value: contentType),
            URLQueryItem(name: "eventId", value: "\(eventId)")
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        print("Fetching presigned URL with contentType: \(contentType), eventId: \(eventId)")

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            print("📡 fetchPresignedUpload Response Status Code: \(httpResponse.statusCode)")
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 fetchPresignedUpload Raw JSON Response:\n\(jsonString)")
        }

        do {
            let decoded = try JSONDecoder().decode(PresignedUpload.self, from: data)
            print("✅ Successfully fetched presigned upload URL.")
            return decoded
        } catch {
            print("🧨 JSON Decoding error: \(error)")
            throw error
        }
    }

}
