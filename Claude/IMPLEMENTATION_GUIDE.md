# CinemaLog 実装ガイド

## 実装手順

### Step 1: 新規プロジェクト作成

1. **Xcode で新規プロジェクト作成**
   ```
   Template: iOS App
   Product Name: CinemeLog
   Interface: SwiftUI
   Language: Swift
   Use Core Data: ❌ (SwiftData を使用)
   Include Tests: ✅
   ```

2. **プロジェクト設定**
   - Deployment Target: iOS 16.0
   - Capabilities: +CloudKit

### Step 2: 基本ファイル構造作成

#### ディレクトリ構造
```
CinemaLog/
├── Models/
├── Services/
├── Views/
│   └── Components/
├── Design/
└── Localization/
```

### Step 3: SwiftData モデル実装

#### 3.1 Item.swift (基本モデル)
```swift
//
//  Item.swift
//  CinemaLog
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
    
    init(viewingDate: Date, rating: Int, notes: String? = nil, viewingCount: Int, location: String? = nil, watchedWith: String? = nil, isRewatch: Bool = false) {
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
}

extension ViewingRecord {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: viewingDate)
    }
    
    var ratingStars: String {
        String(repeating: "★", count: rating) + String(repeating: "☆", count: 5 - rating)
    }
}
```

#### 3.2 Models/WatchlistItem.swift
```swift
//
//  WatchlistItem.swift
//  CinemeLog
//

import Foundation
import SwiftData

@Model
class WatchlistItem {
    var movie: Movie?
    var addedDate: Date
    var priority: WatchlistPriority
    var notes: String?
    
    init(movie: Movie? = nil, priority: WatchlistPriority = .medium, notes: String? = nil) {
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
}
```

#### 3.3 Models/StreamingService.swift
```swift
//
//  StreamingService.swift
//  CinemeLog
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
    
    // 日本で人気のストリーミングサービス
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
```

### Step 4: TMDBService 実装

#### Services/TMDBService.swift
```swift
//
//  TMDBService.swift
//  CinemeLog
//

import Foundation
import SwiftUI
import SwiftData

class TMDBService: ObservableObject {
    static let shared = TMDBService()
    
    private let apiKey = "bd20aa3d8bf95e6eec2e511eb743ddbe"
    private let baseURL = "https://api.themoviedb.org/3"
    private let imageBaseURL = "https://image.tmdb.org/t/p"
    
    private init() {}
    
    private func languageCode(for language: String) -> String {
        switch language {
        case "en":
            return "en-US"
        default:
            return "ja-JP"
        }
    }
    
    // MARK: - Search Movies
    
    func searchMovies(query: String, language: String = "ja") async throws -> TMDBSearchResponse {
        guard !query.isEmpty else {
            return TMDBSearchResponse(results: [], totalResults: 0, totalPages: 0)
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let langCode = languageCode(for: language)
        let urlString = "\(baseURL)/search/movie?api_key=\(apiKey)&query=\(encodedQuery)&language=\(langCode)"
        
        guard let url = URL(string: urlString) else {
            throw TMDBError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TMDBSearchResponse.self, from: data)
        return response
    }
    
    // MARK: - Get Popular Movies
    
    func getPopularMovies(page: Int = 1, language: String = "ja") async throws -> TMDBSearchResponse {
        let langCode = languageCode(for: language)
        let urlString = "\(baseURL)/movie/popular?api_key=\(apiKey)&language=\(langCode)&page=\(page)"
        
        guard let url = URL(string: urlString) else {
            throw TMDBError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TMDBSearchResponse.self, from: data)
        return response
    }
    
    // MARK: - Get Movie Details
    
    func getMovieDetails(id: Int, language: String = "ja") async throws -> TMDBMovieDetails {
        let langCode = languageCode(for: language)
        let urlString = "\(baseURL)/movie/\(id)?api_key=\(apiKey)&language=\(langCode)&append_to_response=credits"
        
        guard let url = URL(string: urlString) else {
            throw TMDBError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TMDBMovieDetails.self, from: data)
        return response
    }
    
    // MARK: - Image URL Generation
    
    func posterURL(path: String?, size: PosterSize = .w500) -> URL? {
        guard let path = path else { return nil }
        return URL(string: "\(imageBaseURL)/\(size.rawValue)\(path)")
    }
}

// MARK: - Error Types

enum TMDBError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError:
            return "Network error"
        }
    }
}

// MARK: - Image Size Enums

enum PosterSize: String {
    case w92 = "w92"
    case w154 = "w154"
    case w185 = "w185"
    case w342 = "w342"
    case w500 = "w500"
    case w780 = "w780"
    case original = "original"
}

// MARK: - Response Models

struct TMDBSearchResponse: Codable {
    let results: [TMDBMovie]
    let totalResults: Int
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case results
        case totalResults = "total_results"
        case totalPages = "total_pages"
    }
}

struct TMDBMovie: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let releaseDate: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let genreIds: [Int]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case originalTitle = "original_title"
        case overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity
        case genreIds = "genre_ids"
    }
}

struct TMDBMovieDetails: Codable {
    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let releaseDate: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let runtime: Int?
    let budget: Int
    let revenue: Int
    let genres: [TMDBGenre]
    let credits: TMDBCredits?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case originalTitle = "original_title"
        case overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity
        case runtime
        case budget
        case revenue
        case genres
        case credits
    }
}

struct TMDBGenre: Codable, Hashable {
    let id: Int
    let name: String
}

struct TMDBCredits: Codable {
    let cast: [TMDBCastMember]
    let crew: [TMDBCrewMember]
}

struct TMDBCastMember: Codable {
    let id: Int
    let name: String
    let character: String
    let order: Int
}

struct TMDBCrewMember: Codable {
    let id: Int
    let name: String
    let job: String
    let department: String
}

// MARK: - Movie Model Integration

extension TMDBMovie {
    func toSwiftDataMovie() -> Movie {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let releaseDate = releaseDate.flatMap { dateFormatter.date(from: $0) }
        
        return Movie(
            tmdbId: id,
            title: title,
            posterURL: posterPath,
            releaseDate: releaseDate,
            overview: overview.isEmpty ? nil : overview,
            genres: nil,
            director: nil,
            cast: nil
        )
    }
}

extension TMDBMovieDetails {
    func toSwiftDataMovie() -> Movie {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let releaseDate = releaseDate.flatMap { dateFormatter.date(from: $0) }
        
        let director = credits?.crew.first { $0.job == "Director" }?.name
        let cast = credits?.cast.prefix(5).map { $0.name } ?? []
        
        return Movie(
            tmdbId: id,
            title: title,
            posterURL: posterPath,
            releaseDate: releaseDate,
            overview: overview.isEmpty ? nil : overview,
            genres: genres.map { $0.name },
            director: director,
            cast: Array(cast)
        )
    }
}
```

### Step 5: アプリエントリーポイント

#### CinemeLogApp.swift
```swift
//
//  CinemeLogApp.swift
//  CinemeLog
//

import SwiftUI
import SwiftData

@main
struct CinemeLogApp: App {
    @StateObject private var localizationManager = LocalizationManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Movie.self,
            ViewingRecord.self,
            WatchlistItem.self,
            UserStreamingService.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(localizationManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
```

### Step 6: デザインシステム

#### Design/ColorTheme.swift
```swift
//
//  ColorTheme.swift
//  CinemeLog
//

import SwiftUI

struct ColorTheme {
    static let primary = Color.blue
    static let accent = Color.orange
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let text = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let border = Color(.separator)
}
```

#### Design/DesignSystem.swift
```swift
//
//  DesignSystem.swift
//  CinemeLog
//

import SwiftUI

struct DesignSystem {
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
    
    struct Typography {
        static let title = Font.largeTitle.weight(.bold)
        static let headline = Font.headline.weight(.semibold)
        static let body = Font.body
        static let caption = Font.caption
    }
}
```

### Step 7: 基本ビュー実装

#### ContentView.swift
```swift
//
//  ContentView.swift
//  CinemeLog
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        TabView {
            DiscoverView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text(localizationManager.localizedString(for: .discover))
                }
            
            RecordsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text(localizationManager.localizedString(for: .records))
                }
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text(localizationManager.localizedString(for: .statistics))
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text(localizationManager.localizedString(for: .settings))
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocalizationManager())
        .modelContainer(for: [Movie.self, ViewingRecord.self, WatchlistItem.self, UserStreamingService.self], inMemory: true)
}
```

### Step 8: 国際化マネージャー

#### Localization/LocalizationManager.swift
```swift
//
//  LocalizationManager.swift
//  CinemeLog
//

import SwiftUI

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
        }
    }
    
    init() {
        self.currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "ja"
    }
    
    func localizedString(for key: LocalizationKey) -> String {
        switch currentLanguage {
        case "en":
            return key.english
        default:
            return key.japanese
        }
    }
}

enum LocalizationKey {
    // Navigation Titles
    case discover, records, statistics, settings
    
    // Common
    case cancel, save, edit, delete, close, ok
    
    // Movie Discovery
    case discoverMovies, searchMovies, popularMovies, noResults
    
    // Viewing Records
    case viewingRecords, calendar, list, poster, noRecords
    case viewingDate, rating, viewingCount, location, notes
    
    // Statistics
    case totalViewed, thisMonth, averageRating, rewatchRate
    case overallSummary, genreStats, periodStats, ratingDistribution
    
    // Settings
    case language, notifications, dataManagement, icloudBackup
    case japanese, english
    
    // Watchlist
    case watchlist, addToWatchlist, removeFromWatchlist
    case priority, highPriority, mediumPriority, lowPriority
    
    var japanese: String {
        switch self {
        case .discover: return "映画を発見"
        case .records: return "鑑賞記録"
        case .statistics: return "統計"
        case .settings: return "設定"
        case .cancel: return "キャンセル"
        case .save: return "保存"
        case .edit: return "編集"
        case .delete: return "削除"
        case .close: return "閉じる"
        case .ok: return "OK"
        case .discoverMovies: return "映画を発見"
        case .searchMovies: return "映画を検索..."
        case .popularMovies: return "人気の映画"
        case .noResults: return "検索結果が見つかりません"
        case .viewingRecords: return "鑑賞記録"
        case .calendar: return "カレンダー"
        case .list: return "リスト"
        case .poster: return "ポスター"
        case .noRecords: return "鑑賞記録がありません"
        case .viewingDate: return "鑑賞日"
        case .rating: return "評価"
        case .viewingCount: return "鑑賞回数"
        case .location: return "鑑賞場所"
        case .notes: return "メモ"
        case .totalViewed: return "総鑑賞数"
        case .thisMonth: return "今月鑑賞"
        case .averageRating: return "平均評価"
        case .rewatchRate: return "再鑑賞率"
        case .overallSummary: return "全体サマリー"
        case .genreStats: return "ジャンル別統計"
        case .periodStats: return "期間別統計"
        case .ratingDistribution: return "評価分布"
        case .language: return "言語"
        case .notifications: return "通知設定"
        case .dataManagement: return "データ管理"
        case .icloudBackup: return "iCloudバックアップ"
        case .japanese: return "日本語"
        case .english: return "English"
        case .watchlist: return "ウォッチリスト"
        case .addToWatchlist: return "ウォッチリストに追加"
        case .removeFromWatchlist: return "ウォッチリストから削除"
        case .priority: return "優先度"
        case .highPriority: return "高"
        case .mediumPriority: return "中"
        case .lowPriority: return "低"
        }
    }
    
    var english: String {
        switch self {
        case .discover: return "Discover"
        case .records: return "Records"
        case .statistics: return "Statistics"
        case .settings: return "Settings"
        case .cancel: return "Cancel"
        case .save: return "Save"
        case .edit: return "Edit"
        case .delete: return "Delete"
        case .close: return "Close"
        case .ok: return "OK"
        case .discoverMovies: return "Discover Movies"
        case .searchMovies: return "Search movies..."
        case .popularMovies: return "Popular Movies"
        case .noResults: return "No search results found"
        case .viewingRecords: return "Viewing Records"
        case .calendar: return "Calendar"
        case .list: return "List"
        case .poster: return "Poster"
        case .noRecords: return "No viewing records"
        case .viewingDate: return "Viewing Date"
        case .rating: return "Rating"
        case .viewingCount: return "View Count"
        case .location: return "Location"
        case .notes: return "Notes"
        case .totalViewed: return "Total Viewed"
        case .thisMonth: return "This Month"
        case .averageRating: return "Avg Rating"
        case .rewatchRate: return "Rewatch Rate"
        case .overallSummary: return "Overall Summary"
        case .genreStats: return "Genre Statistics"
        case .periodStats: return "Period Statistics"
        case .ratingDistribution: return "Rating Distribution"
        case .language: return "Language"
        case .notifications: return "Notifications"
        case .dataManagement: return "Data Management"
        case .icloudBackup: return "iCloud Backup"
        case .japanese: return "日本語"
        case .english: return "English"
        case .watchlist: return "Watchlist"
        case .addToWatchlist: return "Add to Watchlist"
        case .removeFromWatchlist: return "Remove from Watchlist"
        case .priority: return "Priority"
        case .highPriority: return "High"
        case .mediumPriority: return "Medium"
        case .lowPriority: return "Low"
        }
    }
}
```

## 実装のポイント

### ⚠️ 重要な注意事項

1. **ファイル作成順序を守る**
   - Item.swift → Models/ → Services/ → Views/ の順番で作成
   - 依存関係のあるファイルは後で作成

2. **型名の競合を避ける**
   - TMDB関連の構造体は明確な接頭辞を使用
   - SwiftData モデルと API モデルを明確に分離

3. **プレビュー設定**
   - 各ビューのプレビューには最小限のモデルのみ含める
   - 全モデルを含める必要がない場合は避ける

4. **エラーハンドリング**
   - TMDBService のすべてのメソッドに適切なエラーハンドリング
   - ユーザーに分かりやすいエラーメッセージ

### 推奨実装順序

1. **基本構造**: Item.swift, CinemeLogApp.swift
2. **デザインシステム**: ColorTheme.swift, DesignSystem.swift
3. **国際化**: LocalizationManager.swift
4. **サービス**: TMDBService.swift
5. **モデル**: WatchlistItem.swift, StreamingService.swift
6. **基本ビュー**: ContentView.swift
7. **メインビュー**: DiscoverView.swift, RecordsView.swift等
8. **詳細ビュー・コンポーネント**: 最後に実装

この手順に従うことで、安定したプロジェクト構造を構築できます。
