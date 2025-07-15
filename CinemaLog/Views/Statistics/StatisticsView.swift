//
//  StatisticsView.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import SwiftData
import SwiftUI

struct StatisticsView: View {
    @Query(sort: \ViewingRecord.viewingDate, order: .reverse) private var viewingRecords: [ViewingRecord]
    
    @State private var selectedPeriod: StatisticsPeriod = .allTime
    
    enum StatisticsPeriod: String, CaseIterable {
        case allTime = "全期間"
        case thisYear = "今年"
        case lastYear = "昨年"
        case thisMonth = "今月"
        
        var systemImage: String {
            switch self {
            case .allTime: return "infinity"
            case .thisYear: return "calendar"
            case .lastYear: return "calendar.badge.clock"
            case .thisMonth: return "calendar.day.timeline.left"
            }
        }
    }
    
    private var filteredRecords: [ViewingRecord] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .allTime:
            return viewingRecords
        case .thisYear:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            return viewingRecords.filter { $0.viewingDate >= startOfYear }
        case .lastYear:
            let lastYearStart = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            let lastYearEnd = calendar.dateInterval(of: .year, for: lastYearStart)?.end ?? now
            return viewingRecords.filter { 
                $0.viewingDate >= (calendar.dateInterval(of: .year, for: lastYearStart)?.start ?? lastYearStart) &&
                $0.viewingDate < lastYearEnd
            }
        case .thisMonth:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return viewingRecords.filter { $0.viewingDate >= startOfMonth }
        }
    }
    
    private var statistics: MovieStatistics {
        StatisticsService.calculateMovieStatistics(from: filteredRecords)
    }
    
    private var genreStatistics: [GenreStatistics] {
        StatisticsService.calculateGenreStatistics(from: filteredRecords)
    }
    
    private var ratingDistribution: [RatingDistribution] {
        StatisticsService.calculateRatingDistribution(from: filteredRecords)
    }
    
    private var topRatedMovies: [Movie] {
        StatisticsService.getTopRatedMovies(from: filteredRecords, limit: 3)
    }
    
    private var mostWatchedMovies: [Movie] {
        StatisticsService.getMostWatchedMovies(from: filteredRecords, limit: 3)
    }
    
    private var monthlyStatistics: [MonthlyStatistics] {
        StatisticsService.calculateMonthlyStatistics(from: filteredRecords)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewingRecords.isEmpty {
                    emptyStateView
                } else {
                    statisticsContent
                }
            }
            .navigationTitle("統計")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(Color.themeTextSecondary)
            
            Text("統計データがありません")
                .font(.title2)
                .foregroundColor(Color.themeTextSecondary)
            
            Text("映画を観て記録を追加すると\n統計情報が表示されます")
                .font(.body)
                .foregroundColor(Color.themeTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.themeBackground)
    }
    
    private var statisticsContent: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Period selector
                periodSelector
                
                // Overview statistics
                overviewSection
                
                // Rating distribution
                ratingDistributionSection
                
                // Genre statistics
                genreStatisticsSection
                
                // Monthly trends
                if selectedPeriod == .allTime && monthlyStatistics.count > 1 {
                    monthlyTrendsSection
                }
                
                // Top movies
                topMoviesSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.themeBackground)
    }
    
    private var periodSelector: some View {
        VStack(spacing: 16) {
            HStack {
                Text("期間")
                    .font(.headline)
                    .foregroundColor(Color.themeTextPrimary)
                
                Spacer()
            }
            
            Picker("期間", selection: $selectedPeriod) {
                ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                    Label(period.rawValue, systemImage: period.systemImage)
                        .tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.horizontal, 4)
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.themeAccent.opacity(0.3), Color.themeAccent.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundColor(Color.themeAccent)
                }
                
                Text("観賞統計")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.themeTextPrimary)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                StatisticCard(
                    title: "観賞映画数",
                    value: "\(statistics.totalMovies)",
                    subtitle: "作品",
                    icon: "film",
                    color: Color.themeBlue
                )
                
                StatisticCard(
                    title: "総観賞回数",
                    value: "\(statistics.totalViewings)",
                    subtitle: "回",
                    icon: "eye",
                    color: Color.themeGreen
                )
                
                StatisticCard(
                    title: "平均評価",
                    value: String(format: "%.1f", statistics.averageRating),
                    subtitle: "/ 5.0",
                    icon: "star",
                    color: Color.themeYellow
                )
                
                StatisticCard(
                    title: "再観賞率",
                    value: String(format: "%.1f", statistics.rewatchPercentage),
                    subtitle: "%",
                    icon: "repeat",
                    color: Color.themeOrange
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.themeSecondaryBackground)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.themeTextSecondary.opacity(0.08), lineWidth: 1)
        )
    }
    
    private var ratingDistributionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.themeYellow.opacity(0.3), Color.themeYellow.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(Color.themeYellow)
                }
                
                Text("評価分布")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.themeTextPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                ForEach(ratingDistribution.reversed(), id: \.rating) { distribution in
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            ForEach(1...distribution.rating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.subheadline)
                                    .foregroundColor(Color.themeYellow)
                            }
                        }
                        .frame(width: 80, alignment: .leading)
                        
                        Text("\(distribution.count)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.themeTextPrimary)
                            .frame(width: 40, alignment: .trailing)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.themeTextSecondary.opacity(0.1))
                                    .frame(height: 12)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.themeAccent, Color.themeAccent.opacity(0.6)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * (distribution.percentage / 100), height: 12)
                                    .animation(.easeInOut(duration: 0.8), value: distribution.percentage)
                            }
                        }
                        .frame(height: 12)
                        
                        Text(String(format: "%.1f%%", distribution.percentage))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.themeTextSecondary)
                            .frame(width: 50, alignment: .trailing)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.themeSecondaryBackground)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.themeTextSecondary.opacity(0.08), lineWidth: 1)
        )
    }
    
    private var genreStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.themeAccent.opacity(0.3), Color.themeAccent.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "theatermasks")
                        .font(.title2)
                        .foregroundColor(Color.themeAccent)
                }
                
                Text("ジャンル別統計")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.themeTextPrimary)
                
                Spacer()
            }
            
            if genreStatistics.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "theatermasks")
                        .font(.system(size: 40))
                        .foregroundColor(Color.themeTextSecondary.opacity(0.5))
                    
                    Text("ジャンル情報がありません")
                        .font(.subheadline)
                        .foregroundColor(Color.themeTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 16) {
                    ForEach(genreStatistics.prefix(5), id: \.genre) { genre in
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(genre.genre)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.themeTextPrimary)
                                
                                Text("\(genre.count)回観賞")
                                    .font(.caption)
                                    .foregroundColor(Color.themeTextSecondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                HStack(spacing: 2) {
                                    ForEach(1...Int(genre.averageRating.rounded()), id: \.self) { _ in
                                        Image(systemName: "star.fill")
                                            .font(.caption)
                                            .foregroundColor(Color.themeYellow)
                                    }
                                }
                                .frame(width: 60, alignment: .leading)
                                
                                Text(String(format: "%.1f", genre.averageRating))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.themeTextSecondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.themeYellow.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.themeTertiaryBackground)
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.themeSecondaryBackground)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.themeTextSecondary.opacity(0.08), lineWidth: 1)
        )
    }
    
    private var monthlyTrendsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.themeAccent.opacity(0.3), Color.themeAccent.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundColor(Color.themeAccent)
                }
                
                Text("月別観賞傾向")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.themeTextPrimary)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(monthlyStatistics.suffix(12), id: \.month) { monthly in
                        VStack(spacing: 12) {
                            VStack(spacing: 8) {
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.themeTextSecondary.opacity(0.1))
                                        .frame(width: 32, height: 80)
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.themeAccent, Color.themeAccent.opacity(0.7)]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(width: 32, height: max(CGFloat(monthly.viewingCount * 6), 4))
                                        .animation(.easeInOut(duration: 0.8), value: monthly.viewingCount)
                                    
                                    Text("\(monthly.viewingCount)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 4)
                                }
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(monthly.month)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.themeTextPrimary)
                                
                                Text("\(monthly.year)")
                                    .font(.caption2)
                                    .foregroundColor(Color.themeTextSecondary)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                        .background(Color.themeTertiaryBackground)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.themeSecondaryBackground)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.themeTextSecondary.opacity(0.08), lineWidth: 1)
        )
    }
    
    private var topMoviesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.themeYellow.opacity(0.3), Color.themeYellow.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "trophy")
                        .font(.title2)
                        .foregroundColor(Color.themeYellow)
                }
                
                Text("高評価映画")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.themeTextPrimary)
                
                Spacer()
            }
            
            if topRatedMovies.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.system(size: 40))
                        .foregroundColor(Color.themeTextSecondary.opacity(0.5))
                    
                    Text("評価データがありません")
                        .font(.subheadline)
                        .foregroundColor(Color.themeTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 16) {
                    ForEach(Array(topRatedMovies.enumerated()), id: \.element.id) { index, movie in
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [getRankColor(for: index), getRankColor(for: index).opacity(0.3)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 32, height: 32)
                                
                                Text("\(index + 1)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            AsyncImage(url: posterURL(for: movie)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            }
                            .frame(width: 50, height: 75)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(movie.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.themeTextPrimary)
                                    .lineLimit(2)
                                
                                if let avgRating = movie.averageRating {
                                    HStack(spacing: 8) {
                                        HStack(spacing: 2) {
                                            ForEach(1...Int(avgRating.rounded()), id: \.self) { _ in
                                                Image(systemName: "star.fill")
                                                    .font(.caption)
                                                    .foregroundColor(Color.themeYellow)
                                            }
                                        }
                                        
                                        Text(String(format: "%.1f", avgRating))
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(Color.themeTextSecondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.themeYellow.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                                
                                Text("\(movie.totalViewings)回観賞")
                                    .font(.caption)
                                    .foregroundColor(Color.themeTextSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.themeTertiaryBackground)
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.themeSecondaryBackground)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.themeTextSecondary.opacity(0.08), lineWidth: 1)
        )
    }
    
    private func getRankColor(for index: Int) -> Color {
        switch index {
        case 0: return Color.themeYellow
        case 1: return Color.themeTextSecondary
        case 2: return Color.themeOrange
        default: return Color.themeAccent
        }
    }
    
    private func posterURL(for movie: Movie) -> URL? {
        guard let posterPath = movie.posterURL else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(posterPath)")
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.3), color.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.themeTextPrimary)
                
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(Color.themeTextSecondary)
                    
                    Spacer()
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(Color.themeTextSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.themeTextSecondary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.themeSecondaryBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.themeTextSecondary.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Movie.self, ViewingRecord.self, configurations: config)
    
    // Sample data
    let movies = [
        Movie(tmdbId: 550, title: "ファイト・クラブ", posterURL: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg", genres: ["ドラマ", "スリラー"]),
        Movie(tmdbId: 13, title: "フォレスト・ガンプ", posterURL: "/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg", genres: ["ドラマ"]),
        Movie(tmdbId: 278, title: "ショーシャンクの空に", posterURL: "/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg", genres: ["ドラマ"])
    ]
    
    for (index, movie) in movies.enumerated() {
        let record = ViewingRecord(viewingDate: Date().addingTimeInterval(-Double(index * 86400)), rating: 5 - index)
        record.movie = movie
        container.mainContext.insert(movie)
        container.mainContext.insert(record)
    }
    
    return StatisticsView()
        .modelContainer(container)
}
