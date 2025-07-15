//
//  ViewingRecordService.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import Foundation
import SwiftData

class ViewingRecordService: ObservableObject {
    
    // MARK: - Create
    
    static func createViewingRecord(
        for movie: Movie,
        viewingDate: Date,
        rating: Int,
        notes: String? = nil,
        location: String? = nil,
        watchedWith: String? = nil,
        in context: ModelContext
    ) -> ViewingRecord {
        
        // 再鑑賞チェック
        let existingRecords = movie.viewingRecords
        let isRewatch = !existingRecords.isEmpty
        
        let record = ViewingRecord(
            viewingDate: viewingDate,
            rating: rating,
            notes: notes,
            viewingCount: existingRecords.count + 1,
            location: location,
            watchedWith: watchedWith,
            isRewatch: isRewatch
        )
        
        record.movie = movie
        context.insert(record)
        
        do {
            try context.save()
        } catch {
            print("Failed to save viewing record: \(error)")
        }
        
        return record
    }
    
    // MARK: - Read
    
    static func getAllViewingRecords(in context: ModelContext) -> [ViewingRecord] {
        let descriptor = FetchDescriptor<ViewingRecord>(
            sortBy: [SortDescriptor(\.viewingDate, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch viewing records: \(error)")
            return []
        }
    }
    
    static func getViewingRecords(for movie: Movie) -> [ViewingRecord] {
        return movie.viewingRecords.sorted { $0.viewingDate > $1.viewingDate }
    }
    
    static func getRecentViewingRecords(limit: Int = 10, in context: ModelContext) -> [ViewingRecord] {
        var descriptor = FetchDescriptor<ViewingRecord>(
            sortBy: [SortDescriptor(\.viewingDate, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch recent viewing records: \(error)")
            return []
        }
    }
    
    static func getViewingRecords(
        from startDate: Date,
        to endDate: Date,
        in context: ModelContext
    ) -> [ViewingRecord] {
        let predicate = #Predicate<ViewingRecord> { record in
            record.viewingDate >= startDate && record.viewingDate <= endDate
        }
        
        let descriptor = FetchDescriptor<ViewingRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.viewingDate, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch viewing records for date range: \(error)")
            return []
        }
    }
    
    static func getViewingRecords(withRating rating: Int, in context: ModelContext) -> [ViewingRecord] {
        let predicate = #Predicate<ViewingRecord> { record in
            record.rating == rating
        }
        
        let descriptor = FetchDescriptor<ViewingRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.viewingDate, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch viewing records by rating: \(error)")
            return []
        }
    }
    
    // MARK: - Update
    
    static func updateViewingRecord(
        _ record: ViewingRecord,
        viewingDate: Date? = nil,
        rating: Int? = nil,
        notes: String? = nil,
        location: String? = nil,
        watchedWith: String? = nil,
        in context: ModelContext
    ) {
        if let viewingDate = viewingDate {
            record.viewingDate = viewingDate
        }
        if let rating = rating {
            record.rating = rating
        }
        if let notes = notes {
            record.notes = notes
        }
        if let location = location {
            record.location = location
        }
        if let watchedWith = watchedWith {
            record.watchedWith = watchedWith
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to update viewing record: \(error)")
        }
    }
    
    // MARK: - Delete
    
    static func deleteViewingRecord(_ record: ViewingRecord, in context: ModelContext) {
        context.delete(record)
        
        do {
            try context.save()
        } catch {
            print("Failed to delete viewing record: \(error)")
        }
    }
    
    static func deleteAllViewingRecords(for movie: Movie, in context: ModelContext) {
        let records = movie.viewingRecords
        for record in records {
            context.delete(record)
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to delete all viewing records for movie: \(error)")
        }
    }
    
    // MARK: - Statistics
    
    static func getTotalViewingCount(in context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<ViewingRecord>()
        
        do {
            let records = try context.fetch(descriptor)
            return records.count
        } catch {
            print("Failed to get total viewing count: \(error)")
            return 0
        }
    }
    
    static func getAverageRating(in context: ModelContext) -> Double? {
        let descriptor = FetchDescriptor<ViewingRecord>()
        
        do {
            let records = try context.fetch(descriptor)
            guard !records.isEmpty else { return nil }
            
            let totalRating = records.reduce(0) { $0 + $1.rating }
            return Double(totalRating) / Double(records.count)
        } catch {
            print("Failed to get average rating: \(error)")
            return nil
        }
    }
    
    static func getRewatchRate(in context: ModelContext) -> Double? {
        let descriptor = FetchDescriptor<ViewingRecord>()
        
        do {
            let records = try context.fetch(descriptor)
            guard !records.isEmpty else { return nil }
            
            let rewatchCount = records.filter { $0.isRewatch }.count
            return Double(rewatchCount) / Double(records.count) * 100
        } catch {
            print("Failed to get rewatch rate: \(error)")
            return nil
        }
    }
    
    static func getMonthlyViewingCount(for year: Int, in context: ModelContext) -> [Int: Int] {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let endOfYear = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
        
        let records = getViewingRecords(from: startOfYear, to: endOfYear, in: context)
        
        var monthlyCount: [Int: Int] = [:]
        for month in 1...12 {
            monthlyCount[month] = 0
        }
        
        for record in records {
            let month = calendar.component(.month, from: record.viewingDate)
            monthlyCount[month, default: 0] += 1
        }
        
        return monthlyCount
    }
}