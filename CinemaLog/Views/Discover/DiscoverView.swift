//
//  DiscoverView.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import SwiftData
import SwiftUI

struct DiscoverView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var movies: [Movie]
    @Query private var watchlistItems: [WatchlistItem]
    
    @State private var selectedTab: DiscoverTab = .popular
    @State private var searchText = ""
    
    enum DiscoverTab: String, CaseIterable {
        case popular = "人気の映画"
        case watchlist = "ウォッチリスト"
        case available = "今見れる"
        
        var systemImage: String {
            switch self {
            case .popular: return "flame"
            case .watchlist: return "bookmark"
            case .available: return "tv"
            }
        }
    }
    
    private var filteredMovies: [Movie] {
        if searchText.isEmpty {
            return movies
        } else {
            return movies.filter { movie in
                movie.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                tabPicker
                
                // Search Bar
                searchBar
                
                // Content
                contentView
            }
            .navigationTitle("映画を発見")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("サンプルデータ") {
                        SampleDataManager.createSampleData(in: modelContext)
                    }
                    .font(.caption)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // フィルター機能（後で実装）
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(Color.themeAccent)
                    }
                }
            }
        }
    }
    
    private var tabPicker: some View {
        Picker("カテゴリ", selection: $selectedTab) {
            ForEach(DiscoverTab.allCases, id: \.self) { tab in
                Label(tab.rawValue, systemImage: tab.systemImage)
                    .tag(tab)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.themeTextSecondary)
            
            TextField("映画を検索...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case .popular:
            popularMoviesView
        case .watchlist:
            watchlistView
        case .available:
            availableMoviesView
        }
    }
    
    private var popularMoviesView: some View {
        Group {
            if filteredMovies.isEmpty && searchText.isEmpty {
                emptyStateView
            } else if filteredMovies.isEmpty && !searchText.isEmpty {
                searchEmptyView
            } else {
                movieGridView
            }
        }
    }
    
    private var watchlistView: some View {
        Group {
            if watchlistItems.isEmpty {
                emptyWatchlistView
            } else {
                watchlistGridView
            }
        }
    }
    
    private var emptyWatchlistView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark")
                .font(.system(size: 60))
                .foregroundColor(Color.themeTextSecondary)
            
            Text("ウォッチリストは空です")
                .font(.title2)
                .foregroundColor(Color.themeTextSecondary)
            
            Text("気になる映画をウォッチリストに追加しましょう")
                .font(.body)
                .foregroundColor(Color.themeTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var watchlistGridView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(sortedWatchlistItems) { item in
                    if let movie = item.movie {
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            WatchlistMovieGridItem(movie: movie, item: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(action: {
                                WatchlistService.removeFromWatchlist(movie: movie, in: modelContext)
                            }) {
                                Label("ウォッチリストから削除", systemImage: "bookmark.slash")
                            }
                            
                            Button(action: {
                                // Mark as watched functionality could be added here
                            }) {
                                Label("鑑賞済みにする", systemImage: "eye.fill")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    private var sortedWatchlistItems: [WatchlistItem] {
        let filtered = watchlistItems.filter { item in
            if searchText.isEmpty { return true }
            return item.movie?.title.localizedCaseInsensitiveContains(searchText) ?? false
        }
        
        return filtered.sorted { item1, item2 in
            if item1.priority.sortOrder != item2.priority.sortOrder {
                return item1.priority.sortOrder < item2.priority.sortOrder
            }
            return item1.addedDate > item2.addedDate
        }
    }
    
    private var availableMoviesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tv")
                .font(.system(size: 60))
                .foregroundColor(Color.themeTextSecondary)
            
            Text("今見れる映画")
                .font(.title2)
                .foregroundColor(Color.themeTextSecondary)
            
            Text("ストリーミングサービスの設定後に\n視聴可能な映画を表示します")
                .font(.body)
                .foregroundColor(Color.themeTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "film")
                .font(.system(size: 60))
                .foregroundColor(Color.themeTextSecondary)
            
            Text("映画がありません")
                .font(.title2)
                .foregroundColor(Color.themeTextSecondary)
            
            Text("サンプルデータを作成して映画を表示しましょう")
                .font(.body)
                .foregroundColor(Color.themeTextSecondary)
                .multilineTextAlignment(.center)
            
            Button("サンプルデータを作成") {
                SampleDataManager.createSampleData(in: modelContext)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var searchEmptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(Color.themeTextSecondary)
            
            Text("検索結果が見つかりません")
                .font(.title2)
                .foregroundColor(Color.themeTextSecondary)
            
            Text("「\(searchText)」に一致する映画が見つかりませんでした")
                .font(.body)
                .foregroundColor(Color.themeTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var movieGridView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(filteredMovies) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        MovieGridItem(movie: movie)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

struct MovieGridItem: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster
            AsyncImage(url: posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                            Text("ポスター")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 4)
            
            // Movie info
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if let year = movie.releaseYear {
                    Text(year)
                        .font(.caption)
                        .foregroundColor(Color.themeTextSecondary)
                }
                
                if !movie.genreText.isEmpty {
                    Text(movie.genreText)
                        .font(.caption)
                        .foregroundColor(Color.themeTextSecondary)
                        .lineLimit(1)
                }
                
                // Viewing statistics
                if movie.totalViewings > 0 {
                    HStack {
                        Image(systemName: "eye.fill")
                            .font(.caption2)
                            .foregroundColor(Color.themeAccent)
                        
                        Text("\(movie.totalViewings)回鑑賞")
                            .font(.caption2)
                            .foregroundColor(Color.themeAccent)
                        
                        if let avgRating = movie.averageRating {
                            Spacer()
                            
                            HStack(spacing: 1) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(Color.themeYellow)
                                Text(String(format: "%.1f", avgRating))
                                    .font(.caption2)
                                    .foregroundColor(Color.themeTextSecondary)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var posterURL: URL? {
        guard let posterPath = movie.posterURL else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)")
    }
}

struct WatchlistMovieGridItem: View {
    let movie: Movie
    let item: WatchlistItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                // Poster
                AsyncImage(url: posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                                Text("ポスター")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                }
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Priority badge
                VStack {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(priorityColor.opacity(0.9))
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "flag.fill")
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                        .padding(6)
                    }
                    
                    Spacer()
                }
                
                // Added date
                VStack {
                    Spacer()
                    
                    HStack {
                        Text(item.shortFormattedAddedDate)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(6)
                        
                        Spacer()
                    }
                    .padding(6)
                }
            }
            .shadow(radius: 4)
            
            // Movie info
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if let year = movie.releaseYear {
                    Text(year)
                        .font(.caption)
                        .foregroundColor(Color.themeTextSecondary)
                }
                
                if !movie.genreText.isEmpty {
                    Text(movie.genreText)
                        .font(.caption)
                        .foregroundColor(Color.themeTextSecondary)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var priorityColor: Color {
        switch item.priority {
        case .high:
            return Color.themeOrange
        case .medium:
            return Color.themeOrange.opacity(0.7)
        case .low:
            return Color.themeOrange.opacity(0.4)
        }
    }
    
    private var posterURL: URL? {
        guard let posterPath = movie.posterURL else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Movie.self, ViewingRecord.self, configurations: config)
    
    // Sample movies
    let movies = [
        Movie(tmdbId: 550, title: "ファイト・クラブ", posterURL: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg", genres: ["ドラマ", "スリラー"]),
        Movie(tmdbId: 13, title: "フォレスト・ガンプ", posterURL: "/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg", genres: ["ドラマ"]),
        Movie(tmdbId: 278, title: "ショーシャンクの空に", posterURL: "/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg", genres: ["ドラマ"])
    ]
    
    for movie in movies {
        container.mainContext.insert(movie)
    }
    
    return DiscoverView()
        .modelContainer(container)
}
