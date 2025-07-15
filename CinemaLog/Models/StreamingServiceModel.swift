//
//  StreamingService.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import Foundation
import SwiftData

@Model
class UserStreamingService {
    var serviceId: String
    var serviceName: String
    var isEnabled: Bool
    var addedDate: Date
    
    init(serviceId: String, serviceName: String, isEnabled: Bool = true) {
        self.serviceId = serviceId
        self.serviceName = serviceName
        self.isEnabled = isEnabled
        self.addedDate = Date()
    }
}

struct StreamingService: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let iconName: String
    let color: String
    let country: String
    
    static let popularInJapan: [StreamingService] = [
        StreamingService(id: "8", name: "Netflix", iconName: "tv", color: "red", country: "JP"),
        StreamingService(id: "119", name: "Amazon Prime Video", iconName: "play.tv", color: "blue", country: "JP"),
        StreamingService(id: "337", name: "Disney Plus", iconName: "star.circle", color: "blue", country: "JP"),
        StreamingService(id: "2", name: "Apple TV Plus", iconName: "tv.circle", color: "black", country: "JP"),
        StreamingService(id: "283", name: "Crunchyroll", iconName: "tv", color: "orange", country: "JP"),
        StreamingService(id: "38", name: "Hulu", iconName: "tv", color: "green", country: "JP"),
        StreamingService(id: "350", name: "Apple TV", iconName: "tv.circle", color: "gray", country: "JP"),
        StreamingService(id: "68", name: "Microsoft Store", iconName: "tv", color: "blue", country: "JP"),
        StreamingService(id: "3", name: "Google Play Movies", iconName: "tv", color: "green", country: "JP")
    ]
}

// MARK: - TMDB API Models

struct TMDBWatchProvider: Codable {
    let id: Int
    let name: String
    let logoPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "provider_id"
        case name = "provider_name"
        case logoPath = "logo_path"
    }
}

struct TMDBWatchProvidersResponse: Codable {
    let id: Int
    let results: [String: TMDBRegionProviders]
}

struct TMDBRegionProviders: Codable {
    let link: String?
    let flatrate: [TMDBWatchProvider]?
    let rent: [TMDBWatchProvider]?
    let buy: [TMDBWatchProvider]?
}

// MARK: - Extensions

extension UserStreamingService {
    var formattedAddedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: addedDate)
    }
}

extension StreamingService {
    func toUserStreamingService(isEnabled: Bool = true) -> UserStreamingService {
        return UserStreamingService(serviceId: id, serviceName: name, isEnabled: isEnabled)
    }
}