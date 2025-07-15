//
//  WatchlistItem.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import Foundation
import SwiftData

@Model
class WatchlistItem {
    var id: UUID
    var addedDate: Date
    var priority: WatchlistPriority
    var notes: String?
    
    @Relationship(deleteRule: .nullify)
    var movie: Movie?
    
    init(movie: Movie? = nil, priority: WatchlistPriority = .medium, notes: String? = nil) {
        self.id = UUID()
        self.movie = movie
        self.addedDate = Date()
        self.priority = priority
        self.notes = notes
    }
}

enum WatchlistPriority: String, CaseIterable, Codable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    var localizedTitle: String {
        switch self {
        case .high: return "高"
        case .medium: return "中"
        case .low: return "低"
        }
    }
    
    var localizedTitleEnglish: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
    
    var color: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "gray"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

// MARK: - Extensions

extension WatchlistItem {
    var formattedAddedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: addedDate)
    }
    
    var shortFormattedAddedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: addedDate)
    }
}