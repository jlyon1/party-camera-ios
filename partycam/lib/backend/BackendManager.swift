//
//  BackendManager.swift
//  partycam
//
//  Created by Joey Lyon on 5/16/25.
//

import Foundation


struct EventImageAsset: Decodable {
    let id: String
    let size: String
    let width: Int
    let height: Int
    let url: String
    let presignedUrl: String
}

struct EventImage: Decodable {
    let id: String
    let url: String
    let uploadDate: String
    let assets: [EventImageAsset]
}

struct Event: Decodable, Identifiable {
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
        if let assetUrl = eventImage?.assets.first?.url, let url = URL(string: assetUrl) {
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
}

class LiveBackendManager: BackendManager {
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
}
