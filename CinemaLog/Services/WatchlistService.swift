//
//  WatchlistService.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/15.
//

import Foundation
import SwiftData

class WatchlistService {
    
    // MARK: - Add/Remove Operations
    
    static func addToWatchlist(movie: Movie, priority: WatchlistPriority = .medium, in context: ModelContext) {
        // Check if movie is already in watchlist
        if isInWatchlist(movie: movie, in: context) {
            return
        }
        
        let watchlistItem = WatchlistItem(movie: movie, priority: priority, notes: nil)
        context.insert(watchlistItem)
        
        do {
            try context.save()
        } catch {
            print("Error adding to watchlist: \(error)")
        }
    }
    
    static func removeFromWatchlist(movie: Movie, in context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<WatchlistItem>()
        
        do {
            let watchlistItems = try context.fetch(fetchDescriptor)
            let itemsToDelete = watchlistItems.filter { $0.movie?.id == movie.id }
            for item in itemsToDelete {
                context.delete(item)
            }
            try context.save()
        } catch {
            print("Error removing from watchlist: \(error)")
        }
    }
    
    static func toggleWatchlist(movie: Movie, in context: ModelContext) {
        if isInWatchlist(movie: movie, in: context) {
            removeFromWatchlist(movie: movie, in: context)
        } else {
            addToWatchlist(movie: movie, in: context)
        }
    }
    
    // MARK: - Query Operations
    
    static func isInWatchlist(movie: Movie, in context: ModelContext) -> Bool {
        let fetchDescriptor = FetchDescriptor<WatchlistItem>()
        
        do {
            let watchlistItems = try context.fetch(fetchDescriptor)
            return watchlistItems.contains { $0.movie?.id == movie.id }
        } catch {
            print("Error checking watchlist status: \(error)")
            return false
        }
    }
    
    static func getWatchlistItem(for movie: Movie, in context: ModelContext) -> WatchlistItem? {
        let fetchDescriptor = FetchDescriptor<WatchlistItem>()
        
        do {
            let watchlistItems = try context.fetch(fetchDescriptor)
            return watchlistItems.first { $0.movie?.id == movie.id }
        } catch {
            print("Error getting watchlist item: \(error)")
            return nil
        }
    }
    
    static func getAllWatchlistItems(in context: ModelContext) -> [WatchlistItem] {
        let fetchDescriptor = FetchDescriptor<WatchlistItem>()
        
        do {
            let items = try context.fetch(fetchDescriptor)
            return items.sorted { item1, item2 in
                if item1.priority.sortOrder != item2.priority.sortOrder {
                    return item1.priority.sortOrder < item2.priority.sortOrder
                }
                return item1.addedDate > item2.addedDate
            }
        } catch {
            print("Error fetching watchlist items: \(error)")
            return []
        }
    }
    
    // MARK: - Priority Management
    
    static func updatePriority(for movie: Movie, to priority: WatchlistPriority, in context: ModelContext) {
        guard let watchlistItem = getWatchlistItem(for: movie, in: context) else { return }
        
        watchlistItem.priority = priority
        
        do {
            try context.save()
        } catch {
            print("Error updating priority: \(error)")
        }
    }
    
    
    // MARK: - Statistics
    
    static func getWatchlistStatistics(in context: ModelContext) -> WatchlistStatistics {
        let allItems = getAllWatchlistItems(in: context)
        
        let totalItems = allItems.count
        let highPriorityCount = allItems.filter { $0.priority == .high }.count
        let mediumPriorityCount = allItems.filter { $0.priority == .medium }.count
        let lowPriorityCount = allItems.filter { $0.priority == .low }.count
        
        
        // Calculate average days in watchlist
        let currentDate = Date()
        let totalDaysInWatchlist = allItems.reduce(0) { total, item in
            let daysInWatchlist = Calendar.current.dateComponents([.day], from: item.addedDate, to: currentDate).day ?? 0
            return total + daysInWatchlist
        }
        let averageDaysInWatchlist = totalItems > 0 ? Double(totalDaysInWatchlist) / Double(totalItems) : 0.0
        
        return WatchlistStatistics(
            totalItems: totalItems,
            highPriorityCount: highPriorityCount,
            mediumPriorityCount: mediumPriorityCount,
            lowPriorityCount: lowPriorityCount,
            averageDaysInWatchlist: averageDaysInWatchlist
        )
    }
    
    // MARK: - Bulk Operations
    
    static func clearWatchlist(in context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<WatchlistItem>()
        
        do {
            let allItems = try context.fetch(fetchDescriptor)
            for item in allItems {
                context.delete(item)
            }
            try context.save()
        } catch {
            print("Error clearing watchlist: \(error)")
        }
    }
    
    static func markAsWatched(movie: Movie, rating: Int, in context: ModelContext) {
        // Remove from watchlist
        removeFromWatchlist(movie: movie, in: context)
        
        // Add to viewing records
        let viewingRecord = ViewingRecord(
            viewingDate: Date(),
            rating: rating
        )
        viewingRecord.movie = movie
        
        context.insert(viewingRecord)
        
        do {
            try context.save()
        } catch {
            print("Error marking as watched: \(error)")
        }
    }
}

// MARK: - Supporting Types

struct WatchlistStatistics {
    let totalItems: Int
    let highPriorityCount: Int
    let mediumPriorityCount: Int
    let lowPriorityCount: Int
    let averageDaysInWatchlist: Double
}