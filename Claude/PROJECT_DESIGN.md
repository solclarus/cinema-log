# CinemaLog - 映画鑑賞記録アプリ 設計書

## プロジェクト概要

### アプリ名
CinemaLog (シネリウォッチ)

### 目的
映画の鑑賞記録を管理し、統計情報を表示する個人用アプリケーション

### 主要機能
- 映画の検索・追加（TMDB API連携）
- 鑑賞記録の管理
- 統計情報の表示
- ウォッチリスト機能
- ストリーミングサービス対応

## 技術スタック

### フレームワーク
- **SwiftUI** (iOS 16.0+)
- **SwiftData** (データ永続化)
- **CloudKit** (iCloudバックアップ)

### 外部API
- **TMDB API** (The Movie Database)
  - API Key: `bd20aa3d8bf95e6eec2e511eb743ddbe`
  - Base URL: `https://api.themoviedb.org/3`

### アーキテクチャ
- MVVM パターン
- ObservableObject を使用した状態管理
- SwiftData の @Model マクロ使用

## データモデル設計

### 1. Movie (映画)
```swift
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
}
```

### 2. ViewingRecord (鑑賞記録)
```swift
@Model
final class ViewingRecord {
    var id: UUID
    var viewingDate: Date
    var rating: Int // 1-5
    var notes: String?
    var viewingCount: Int
    var location: String?
    var watchedWith: String?
    var isRewatch: Bool
    
    @Relationship(deleteRule: .nullify)
    var movie: Movie?
}
```

### 3. WatchlistItem (ウォッチリスト)
```swift
@Model
class WatchlistItem {
    var movie: Movie?
    var addedDate: Date
    var priority: WatchlistPriority
    var notes: String?
}

enum WatchlistPriority: String, CaseIterable, Codable {
    case high = "high"
    case medium = "medium"
    case low = "low"
}
```

### 4. UserStreamingService (ストリーミングサービス)
```swift
@Model
class UserStreamingService {
    var serviceId: String
    var serviceName: String
    var isEnabled: Bool
    var addedDate: Date
}
```

## API モデル設計

### TMDB API レスポンス
```swift
struct TMDBSearchResponse: Codable {
    let results: [TMDBMovie]
    let totalResults: Int
    let totalPages: Int
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
}
```

## ファイル構造

```
CinemaLog/
├── CinemaLogApp.swift              # メインアプリ
├── ContentView.swift               # メインビュー
├── Item.swift                      # SwiftDataモデル
├── Models/
│   ├── WatchlistItem.swift         # ウォッチリストモデル
│   └── StreamingService.swift      # ストリーミングサービスモデル
├── Services/
│   └── TMDBService.swift           # TMDB API サービス
├── Views/
│   ├── DiscoverView.swift          # 映画発見
│   ├── RecordsView.swift           # 鑑賞記録一覧
│   ├── StatisticsView.swift        # 統計表示
│   ├── SettingsView.swift          # 設定画面
│   ├── MovieDetailView.swift       # 映画詳細
│   ├── ViewingRecordView.swift     # 鑑賞記録追加・編集
│   ├── TMDBMovieDetailView.swift   # TMDB映画詳細
│   ├── StreamingServicesSettingsView.swift # ストリーミング設定
│   └── Components/
│       ├── WatchlistView.swift     # ウォッチリスト
│       ├── AsyncPosterImage.swift  # ポスター画像
│       └── [その他コンポーネント]
├── Design/
│   ├── ColorTheme.swift            # カラーテーマ
│   └── DesignSystem.swift          # デザインシステム
├── Localization/
│   └── LocalizationManager.swift   # 国際化管理
└── SampleDataManager.swift         # サンプルデータ
```

## 画面設計

### 1. タブナビゲーション
- **発見** (Discover): 映画検索・追加
- **記録** (Records): 鑑賞記録一覧
- **統計** (Statistics): 統計情報
- **設定** (Settings): アプリ設定

### 2. 発見タブ
- **人気の映画**: TMDB人気映画一覧
- **今見れる**: ストリーミングサービスフィルター対応
- **ウォッチリスト**: 見たい映画リスト

### 3. 記録タブ
- **カレンダー表示**: 日付別鑑賞記録
- **リスト表示**: 時系列鑑賞記録
- **ポスター表示**: ポスターグリッド

### 4. 統計タブ
- **概要**: 総鑑賞数、平均評価、再鑑賞率
- **期間別**: 月別・年別統計
- **ジャンル別**: ジャンル統計
- **評価分布**: 評価の分布グラフ

## 機能仕様

### 映画検索・追加
1. TMDB API で映画検索
2. 映画詳細表示（ポスター、あらすじ、キャスト等）
3. 鑑賞記録追加
4. ウォッチリスト追加

### 鑑賞記録管理
1. 鑑賞日時入力
2. 評価（1-5星）
3. メモ入力
4. 鑑賞場所・同伴者
5. 再鑑賞フラグ

### ストリーミングサービス
1. 対応サービス選択（Netflix, Amazon Prime Video等）
2. サービス別フィルタリング
3. 視聴可能作品表示

### 統計機能
1. **基本統計**
   - 総鑑賞数
   - 今月の鑑賞数
   - 平均評価
   - 再鑑賞率

2. **期間別統計**
   - 月別鑑賞数グラフ
   - 年別鑑賞数
   - 最も活発な月/年

3. **ジャンル統計**
   - ジャンル別鑑賞数
   - ジャンル別平均評価

4. **その他**
   - 評価分布
   - 鑑賞ランキング

## 国際化対応

### 対応言語
- 日本語 (デフォルト)
- 英語

### LocalizationKey 構造
```swift
enum LocalizationKey {
    // ナビゲーション
    case discover, records, statistics, settings
    
    // 共通
    case cancel, save, edit, delete, close, ok
    
    // 映画発見
    case discoverMovies, searchMovies, popularMovies
    
    // 鑑賞記録
    case viewingRecords, calendar, list, poster
    case viewingDate, rating, viewingCount, location, notes
    
    // 統計
    case totalViewed, thisMonth, averageRating, rewatchRate
    case overallSummary, genreStats, periodStats, ratingDistribution
    
    // 設定
    case language, notifications, dataManagement, icloudBackup
    
    // [その他...]
}
```

## セットアップ手順

### 1. 新規プロジェクト作成
```bash
# Xcode で新規プロジェクト作成
# プロジェクト名: CinemaLog
# Interface: SwiftUI
# Language: Swift
# Use Core Data: NO (SwiftData使用)
# Include Tests: YES
```

### 2. 必要な設定
1. **Deployment Target**: iOS 16.0
2. **Capabilities**: CloudKit
3. **Info.plist**: 
   - NSAppTransportSecurity の設定（HTTP通信許可）

### 3. パッケージ依存関係
現在は外部パッケージ不使用（標準フレームワークのみ）

### 4. API設定
```swift
// TMDBService.swift
private let apiKey = "bd20aa3d8bf95e6eec2e511eb743ddbe"
private let baseURL = "https://api.themoviedb.org/3"
private let imageBaseURL = "https://image.tmdb.org/t/p"
```

## 実装優先順位

### Phase 1: 基本機能
1. SwiftData モデル定義
2. TMDB API サービス
3. 映画検索・追加機能
4. 基本的な鑑賞記録機能

### Phase 2: UI改善
1. デザインシステム
2. 統計表示
3. カレンダー表示
4. 詳細画面

### Phase 3: 高度な機能
1. ウォッチリスト
2. ストリーミングサービス対応
3. 国際化
4. CloudKit 同期

### Phase 4: 最適化
1. パフォーマンス改善
2. エラーハンドリング
3. アクセシビリティ
4. テスト

## 注意事項

### 技術的制約
1. **SwiftData**: iOS 16.0+ 必須
2. **TMDB API**: レート制限あり（40リクエスト/10秒）
3. **CloudKit**: Apple ID 必須

### 設計原則
1. **Single Responsibility**: 各ファイルは単一の責務
2. **MVVM**: ビューとロジックの分離
3. **Composition over Inheritance**: 継承より合成
4. **Fail Fast**: 早期エラー検出

### パフォーマンス考慮
1. **画像キャッシング**: AsyncImage 使用
2. **データページング**: 大量データ対応
3. **レイジーローディング**: LazyVStack/LazyHStack 使用

## テスト戦略

### 単体テスト
- モデルロジック
- API サービス
- ユーティリティ関数

### UI テスト
- 主要な画面遷移
- データ入力フロー
- エラーハンドリング

### パフォーマンステスト
- 大量データ処理
- 画像読み込み
- API レスポンス

---

この設計書に基づいて新しいプロジェクトを作成することで、より安定した構造のアプリケーションを構築できます。
