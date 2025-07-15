//
//  MovieModel.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import Foundation
import SwiftData

@Model
final class Movie {
    var id: UUID
    var tmdbId: Int
    var title: String
    var posterURL: String?
    var releaseDate: Date?
    var overview: String?
    var genres: [String]?
    var director: String?
    var cast: [String]?
    
    @Relationship(deleteRule: .cascade, inverse: \ViewingRecord.movie)
    var viewingRecords: [ViewingRecord] = []
    
    init(tmdbId: Int, title: String, posterURL: String? = nil, releaseDate: Date? = nil, overview: String? = nil, genres: [String]? = nil, director: String? = nil, cast: [String]? = nil) {
        self.id = UUID()
        self.tmdbId = tmdbId
        self.title = title
        self.posterURL = posterURL
        self.releaseDate = releaseDate
        self.overview = overview
        self.genres = genres
        self.director = director
        self.cast = cast
    }
}

// MARK: - Extensions

extension Movie {
    var averageRating: Double? {
        guard !viewingRecords.isEmpty else { return nil }
        let totalRating = viewingRecords.reduce(0) { $0 + $1.rating }
        return Double(totalRating) / Double(viewingRecords.count)
    }
    
    var totalViewings: Int {
        viewingRecords.count
    }
    
    var isRewatched: Bool {
        viewingRecords.count > 1
    }
    
    var lastViewingDate: Date? {
        viewingRecords.max(by: { $0.viewingDate < $1.viewingDate })?.viewingDate
    }
    
    var genreText: String {
        genres?.joined(separator: ", ") ?? ""
    }
    
    var releaseYear: String? {
        guard let releaseDate = releaseDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: releaseDate)
    }
    
    var castText: String {
        cast?.joined(separator: ", ") ?? ""
    }
    
    var shortOverview: String {
        guard let overview = overview else { return "" }
        if overview.count <= 100 {
            return overview
        }
        let index = overview.index(overview.startIndex, offsetBy: 100)
        return String(overview[..<index]) + "..."
    }
}