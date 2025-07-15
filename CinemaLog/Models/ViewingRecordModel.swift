//
//  ViewingRecord.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import Foundation
import SwiftData

@Model
final class ViewingRecord {
    var id: UUID
    var viewingDate: Date
    var rating: Int
    var notes: String?
    var viewingCount: Int
    var location: String?
    var watchedWith: String?
    var isRewatch: Bool
    
    @Relationship(deleteRule: .nullify)
    var movie: Movie?
    
    init(viewingDate: Date, rating: Int, notes: String? = nil, viewingCount: Int = 1, location: String? = nil, watchedWith: String? = nil, isRewatch: Bool = false) {
        self.id = UUID()
        self.viewingDate = viewingDate
        self.rating = rating
        self.notes = notes
        self.viewingCount = viewingCount
        self.location = location
        self.watchedWith = watchedWith
        self.isRewatch = isRewatch
    }
}

// MARK: - Extensions

extension ViewingRecord {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: viewingDate)
    }
    
    var ratingStars: String {
        String(repeating: "★", count: rating) + String(repeating: "☆", count: 5 - rating)
    }
    
    var shortFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: viewingDate)
    }
    
    var fullFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: viewingDate)
    }
    
    var timeFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: viewingDate)
    }
    
    var isValidRating: Bool {
        rating >= 1 && rating <= 5
    }
    
    var hasNotes: Bool {
        notes != nil && !notes!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var shortNotes: String? {
        guard let notes = notes else { return nil }
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedNotes.count <= 50 {
            return trimmedNotes
        }
        let index = trimmedNotes.index(trimmedNotes.startIndex, offsetBy: 50)
        return String(trimmedNotes[..<index]) + "..."
    }
}