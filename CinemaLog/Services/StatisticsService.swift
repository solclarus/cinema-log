//
//  StatisticsService.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/15.
//

import Foundation
import SwiftData

struct MovieStatistics {
    let totalMovies: Int
    let totalViewings: Int
    let averageRating: Double
    let totalRatings: Int
    let totalWatchTime: Int // in minutes (estimated)
    let mostWatchedGenre: String?
    let favoriteDecade: String?
    let averageMoviesPerMonth: Double
    let rewatchCount: Int
    let rewatchPercentage: Double
}

struct GenreStatistics {
    let genre: String
    let count: Int
    let percentage: Double
    let averageRating: Double
}

struct RatingDistribution {
    let rating: Int
    let count: Int
    let percentage: Double
}

struct MonthlyStatistics {
    let month: String
    let year: Int
    let viewingCount: Int
    let averageRating: Double
}

class StatisticsService {
    
    // MARK: - Main Statistics
    
    static func calculateMovieStatistics(from viewingRecords: [ViewingRecord]) -> MovieStatistics {
        let uniqueMovies = Set(viewingRecords.compactMap { $0.movie?.id })
        let totalMovies = uniqueMovies.count
        let totalViewings = viewingRecords.count
        
        // Average rating calculation
        let validRatings = viewingRecords.filter { $0.isValidRating }
        let averageRating = validRatings.isEmpty ? 0.0 : 
            Double(validRatings.reduce(0) { $0 + $1.rating }) / Double(validRatings.count)
        
        // Most watched genre
        let mostWatchedGenre = calculateMostWatchedGenre(from: viewingRecords)
        
        // Favorite decade
        let favoriteDecade = calculateFavoriteDecade(from: viewingRecords)
        
        // Average movies per month
        let averageMoviesPerMonth = calculateAverageMoviesPerMonth(from: viewingRecords)
        
        // Rewatch statistics
        let rewatchCount = viewingRecords.filter { $0.isRewatch }.count
        let rewatchPercentage = totalViewings > 0 ? (Double(rewatchCount) / Double(totalViewings)) * 100 : 0.0
        
        // Estimated total watch time (assume 120 minutes per movie)
        let totalWatchTime = totalViewings * 120
        
        return MovieStatistics(
            totalMovies: totalMovies,
            totalViewings: totalViewings,
            averageRating: averageRating,
            totalRatings: validRatings.count,
            totalWatchTime: totalWatchTime,
            mostWatchedGenre: mostWatchedGenre,
            favoriteDecade: favoriteDecade,
            averageMoviesPerMonth: averageMoviesPerMonth,
            rewatchCount: rewatchCount,
            rewatchPercentage: rewatchPercentage
        )
    }
    
    // MARK: - Genre Statistics
    
    static func calculateGenreStatistics(from viewingRecords: [ViewingRecord]) -> [GenreStatistics] {
        var genreCount: [String: Int] = [:]
        var genreRatings: [String: [Int]] = [:]
        
        for record in viewingRecords {
            guard let genres = record.movie?.genres else { continue }
            
            for genre in genres {
                genreCount[genre, default: 0] += 1
                genreRatings[genre, default: []].append(record.rating)
            }
        }
        
        let totalCount = genreCount.values.reduce(0, +)
        
        return genreCount.map { (genre, count) in
            let percentage = totalCount > 0 ? (Double(count) / Double(totalCount)) * 100 : 0.0
            let ratings = genreRatings[genre] ?? []
            let averageRating = ratings.isEmpty ? 0.0 : Double(ratings.reduce(0, +)) / Double(ratings.count)
            
            return GenreStatistics(
                genre: genre,
                count: count,
                percentage: percentage,
                averageRating: averageRating
            )
        }.sorted { $0.count > $1.count }
    }
    
    // MARK: - Rating Distribution
    
    static func calculateRatingDistribution(from viewingRecords: [ViewingRecord]) -> [RatingDistribution] {
        let validRecords = viewingRecords.filter { $0.isValidRating }
        let totalCount = validRecords.count
        
        var ratingCount: [Int: Int] = [:]
        for record in validRecords {
            ratingCount[record.rating, default: 0] += 1
        }
        
        return (1...5).map { rating in
            let count = ratingCount[rating] ?? 0
            let percentage = totalCount > 0 ? (Double(count) / Double(totalCount)) * 100 : 0.0
            
            return RatingDistribution(
                rating: rating,
                count: count,
                percentage: percentage
            )
        }
    }
    
    // MARK: - Monthly Statistics
    
    static func calculateMonthlyStatistics(from viewingRecords: [ViewingRecord]) -> [MonthlyStatistics] {
        var monthlyData: [String: [ViewingRecord]] = [:]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        
        for record in viewingRecords {
            let monthKey = formatter.string(from: record.viewingDate)
            monthlyData[monthKey, default: []].append(record)
        }
        
        return monthlyData.map { (monthKey, records) in
            let components = monthKey.components(separatedBy: "-")
            let year = Int(components[0]) ?? 0
            let month = components[1]
            
            let monthName = DateFormatter().monthSymbols[Int(month)! - 1]
            let validRatings = records.filter { $0.isValidRating }
            let averageRating = validRatings.isEmpty ? 0.0 : 
                Double(validRatings.reduce(0) { $0 + $1.rating }) / Double(validRatings.count)
            
            return MonthlyStatistics(
                month: monthName,
                year: year,
                viewingCount: records.count,
                averageRating: averageRating
            )
        }.sorted { $0.year < $1.year || ($0.year == $1.year && $0.month < $1.month) }
    }
    
    // MARK: - Helper Methods
    
    private static func calculateMostWatchedGenre(from viewingRecords: [ViewingRecord]) -> String? {
        var genreCount: [String: Int] = [:]
        
        for record in viewingRecords {
            guard let genres = record.movie?.genres else { continue }
            for genre in genres {
                genreCount[genre, default: 0] += 1
            }
        }
        
        return genreCount.max { $0.value < $1.value }?.key
    }
    
    private static func calculateFavoriteDecade(from viewingRecords: [ViewingRecord]) -> String? {
        var decadeCount: [String: Int] = [:]
        
        for record in viewingRecords {
            guard let releaseDate = record.movie?.releaseDate else { continue }
            let year = Calendar.current.component(.year, from: releaseDate)
            let decade = (year / 10) * 10
            let decadeString = "\(decade)s"
            decadeCount[decadeString, default: 0] += 1
        }
        
        return decadeCount.max { $0.value < $1.value }?.key
    }
    
    private static func calculateAverageMoviesPerMonth(from viewingRecords: [ViewingRecord]) -> Double {
        guard !viewingRecords.isEmpty else { return 0.0 }
        
        let sortedRecords = viewingRecords.sorted { $0.viewingDate < $1.viewingDate }
        guard let firstDate = sortedRecords.first?.viewingDate,
              let lastDate = sortedRecords.last?.viewingDate else { return 0.0 }
        
        let calendar = Calendar.current
        let months = calendar.dateComponents([.month], from: firstDate, to: lastDate).month ?? 1
        
        return Double(viewingRecords.count) / Double(max(months, 1))
    }
    
    // MARK: - Top Movies
    
    static func getTopRatedMovies(from viewingRecords: [ViewingRecord], limit: Int = 5) -> [Movie] {
        let movieRatings = Dictionary(grouping: viewingRecords, by: { $0.movie })
            .compactMapValues { records -> (Movie, Double)? in
                guard let movie = records.first?.movie else { return nil }
                let averageRating = Double(records.reduce(0) { $0 + $1.rating }) / Double(records.count)
                return (movie, averageRating)
            }
        
        return movieRatings.values
            .sorted { $0.1 > $1.1 }
            .prefix(limit)
            .map { $0.0 }
    }
    
    static func getMostWatchedMovies(from viewingRecords: [ViewingRecord], limit: Int = 5) -> [Movie] {
        let movieCounts = Dictionary(grouping: viewingRecords, by: { $0.movie })
            .compactMapValues { records -> (Movie, Int)? in
                guard let movie = records.first?.movie else { return nil }
                return (movie, records.count)
            }
        
        return movieCounts.values
            .sorted { $0.1 > $1.1 }
            .prefix(limit)
            .map { $0.0 }
    }
}