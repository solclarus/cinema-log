//
//  ViewingRecordCalendarView.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import SwiftUI
import SwiftData

struct ViewingRecordCalendarView: View {
    @Query(sort: \ViewingRecord.viewingDate, order: .reverse) private var viewingRecords: [ViewingRecord]
    
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    private var calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            // Calendar section
            VStack() {
                // Calendar header and grid
                CalendarGrid(
                    records: viewingRecords,
                    currentMonth: $currentMonth,
                    selectedDate: $selectedDate
                )
                
                // Heatmap legend
                CalendarHeatmapLegend()
            }
            .padding()
            
            // Selected date records
            if !recordsForSelectedDate.isEmpty {
                selectedDateRecords
            }
        }
    }
    
    private var selectedDateRecords: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(selectedDateText)
                    .font(.headline)
                    .padding(.horizontal)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(heatmapColorForCount(recordsForSelectedDate.count))
                        .frame(width: 16, height: 16)
                    
                    Text("\(recordsForSelectedDate.count)件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(recordsForSelectedDate) { record in
                        NavigationLink(destination: ViewingRecordDetailView(record: record)) {
                            CompactRecordCard(record: record)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color.themeSecondaryBackground)
    }
    
    // MARK: - Helper Properties
    
    private var selectedDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日の鑑賞記録"
        return formatter.string(from: selectedDate)
    }
    
    private var recordsForSelectedDate: [ViewingRecord] {
        viewingRecords.filter { record in
            calendar.isDate(record.viewingDate, inSameDayAs: selectedDate)
        }
    }
    
    private func heatmapColorForCount(_ count: Int) -> Color {
        if count == 0 {
            return Color.secondary.opacity(0.1)
        }
        
        let baseColor = Color.orange
        let intensity = min(Double(count) / 3.0, 1.0)
        return baseColor.opacity(0.3 + (intensity * 0.7))
    }
}

struct CalendarGrid: View {
    let records: [ViewingRecord]
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    
    private let calendar = Calendar.current
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month header
            HStack {
                Button {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(Color.themeAccent)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(Color.themeAccent)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Weekday headers
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { dayKey in
                    Text(dayKey)
                        .font(.caption)
                        .foregroundColor(Color.themeTextSecondary)
                        .frame(height: 30)
                }
                
                // Calendar days
                ForEach(calendarDays, id: \.self) { date in
                    CalendarDay(
                        date: date,
                        currentMonth: currentMonth,
                        selectedDate: $selectedDate,
                        recordCount: recordCountForDate(date)
                    )
                }
            }
        }
    }
    
    private var calendarDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let daysToSubtract = (firstWeekday - 1) % 7
        
        guard let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: firstOfMonth) else {
            return []
        }
        
        var days: [Date] = []
        for i in 0..<42 { // 6 weeks × 7 days
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func recordCountForDate(_ date: Date) -> Int {
        records.filter { record in
            calendar.isDate(record.viewingDate, inSameDayAs: date)
        }.count
    }
}

struct CalendarDay: View {
    let date: Date
    let currentMonth: Date
    @Binding var selectedDate: Date
    let recordCount: Int
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button {
            selectedDate = date
        } label: {
            ZStack {
                // Background circle for heatmap
                Circle()
                    .fill(heatmapColor)
                    .frame(width: 32, height: 32)
                
                // Selection indicator
                if calendar.isDate(date, inSameDayAs: selectedDate) {
                    Circle()
                        .stroke(Color.themeAccent, lineWidth: 2)
                        .frame(width: 32, height: 32)
                }
                
                // Day number
                Text("\(calendar.component(.day, from: date))")
                    .font(.caption)
                    .fontWeight(recordCount > 0 ? .semibold : .regular)
                    .foregroundColor(dayTextColor)
            }
            .frame(width: 40, height: 40)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var heatmapColor: Color {
        if recordCount == 0 {
            return Color.clear
        }
        
        let baseColor = Color.orange
        let intensity = min(Double(recordCount) / 3.0, 1.0)
        return baseColor.opacity(0.3 + (intensity * 0.7))
    }
    
    private var dayTextColor: Color {
        if calendar.isDate(date, inSameDayAs: selectedDate) {
            return Color.themeTextPrimary
        }
        
        if !calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
            return Color.themeTextSecondary
        }
        
        return recordCount > 0 ? .white : Color.themeTextPrimary
    }
}

struct CalendarHeatmapLegend: View {
    var body: some View {
        HStack {
            Text("鑑賞記録の多い日:")
                .font(.caption2)
                .foregroundColor(Color.themeTextSecondary)
            
            HStack(spacing: 4) {
                // Light activity
                Circle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: 12, height: 12)
                
                // Medium activity
                Circle()
                    .fill(Color.orange.opacity(0.6))
                    .frame(width: 12, height: 12)
                
                // High activity
                Circle()
                    .fill(Color.orange.opacity(1.0))
                    .frame(width: 12, height: 12)
            }
            
            Text("多")
                .font(.caption2)
                .foregroundColor(Color.themeTextSecondary)
            
            Spacer()
        }
    }
}

fileprivate struct CompactRecordCard: View {
    let record: ViewingRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 80, height: 120)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(record.movie?.title ?? "")
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                HStack {
                    Text(record.ratingStars)
                        .font(.caption2)
                    
                    if record.isRewatch {
                        Text("再")
                            .font(.caption2)
                            .padding(2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(2)
                    }
                }
            }
            .frame(width: 80, alignment: .leading)
        }
    }
    
    private var posterURL: URL? {
        guard let posterPath = record.movie?.posterURL else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(posterPath)")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Movie.self, ViewingRecord.self, configurations: config)
    
    let movie = Movie(tmdbId: 550, title: "ファイト・クラブ", posterURL: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg")
    let record = ViewingRecord(viewingDate: Date(), rating: 5)
    record.movie = movie
    
    container.mainContext.insert(movie)
    container.mainContext.insert(record)
    
    return NavigationStack {
        ViewingRecordCalendarView()
    }
    .modelContainer(container)
    
}
