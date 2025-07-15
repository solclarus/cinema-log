//
//  ViewingRecordFormView.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import SwiftUI
import SwiftData

struct ViewingRecordFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var movies: [Movie]
    
    // Form mode
    enum FormMode {
        case create(Movie)
        case edit(ViewingRecord)
        
        var title: String {
            switch self {
            case .create: return "鑑賞記録追加"
            case .edit: return "鑑賞記録編集"
            }
        }
        
        var saveButtonTitle: String {
            switch self {
            case .create: return "保存"
            case .edit: return "保存"
            }
        }
        
        var movie: Movie {
            switch self {
            case .create(let movie): return movie
            case .edit(let record): return record.movie!
            }
        }
    }
    
    let mode: FormMode
    @State private var viewingDate = Date()
    @State private var rating = 3
    @State private var notes = ""
    @State private var location = ""
    @State private var watchedWith = ""
    
    init(mode: FormMode) {
        self.mode = mode
    }
    
    var body: some View {
        NavigationView {
            Form {
                movieSection
                viewingInfoSection
                detailsSection
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(mode.saveButtonTitle) {
                        saveRecord()
                    }
                }
            }
            .onAppear {
                setupInitialValues()
            }
        }
    }
    
    @ViewBuilder
    private var movieSection: some View {
        Section("映画") {
            movieRow(mode.movie)
        }
    }
    
    private var viewingInfoSection: some View {
        Section("鑑賞情報") {
            DatePicker("鑑賞日", selection: $viewingDate, displayedComponents: .date)
            
            VStack(alignment: .leading) {
                Text("評価")
                RatingPicker(rating: $rating)
            }
        }
    }
    
    private var detailsSection: some View {
        Section("詳細（任意）") {
            TextField("メモ・感想", text: $notes, axis: .vertical)
                .lineLimit(3...6)
            
            TextField("鑑賞場所", text: $location)
            
            TextField("同伴者", text: $watchedWith)
        }
    }
    
    private func movieRow(_ movie: Movie) -> some View {
        HStack {
            AsyncImage(url: posterURL(for: movie)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 40, height: 60)
            .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if let year = movie.releaseYear {
                    Text(year)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !movie.genreText.isEmpty {
                    Text(movie.genreText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
    }
    
    private func posterURL(for movie: Movie) -> URL? {
        guard let posterPath = movie.posterURL else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w154\(posterPath)")
    }
    
    private func setupInitialValues() {
        switch mode {
        case .create:
            // 新規作成モードはデフォルト値をそのまま使用
            break
        case .edit(let record):
            // 編集モードは既存の値で初期化
            viewingDate = record.viewingDate
            rating = record.rating
            notes = record.notes ?? ""
            location = record.location ?? ""
            watchedWith = record.watchedWith ?? ""
        }
    }
    
    private func saveRecord() {
        let movie = mode.movie
        
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedWatchedWith = watchedWith.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch mode {
        case .create:
            // 新しい鑑賞記録を作成
            _ = ViewingRecordService.createViewingRecord(
                for: movie,
                viewingDate: viewingDate,
                rating: rating,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
                location: trimmedLocation.isEmpty ? nil : trimmedLocation,
                watchedWith: trimmedWatchedWith.isEmpty ? nil : trimmedWatchedWith,
                in: modelContext
            )
            
        case .edit(let record):
            // 既存の鑑賞記録を更新
            ViewingRecordService.updateViewingRecord(
                record,
                viewingDate: viewingDate,
                rating: rating,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
                location: trimmedLocation.isEmpty ? nil : trimmedLocation,
                watchedWith: trimmedWatchedWith.isEmpty ? nil : trimmedWatchedWith,
                in: modelContext
            )
        }
        
        dismiss()
    }
}

// MARK: - RatingPicker (shared component)

struct RatingPicker: View {
    @Binding var rating: Int
    
    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                Button {
                    rating = star
                } label: {
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundColor(star <= rating ? .yellow : .gray)
                        .font(.title2)
                }
            }
            
            Spacer()
            
            Text("\(rating)点")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - MovieSelectionView (shared component)

struct MovieSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var movies: [Movie]
    @Binding var selectedMovie: Movie?
    
    @State private var searchText = ""
    
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
        NavigationView {
            VStack {
                if movies.isEmpty {
                    emptyStateView
                } else {
                    List(filteredMovies) { movie in
                        movieSelectionRow(movie)
                            .onTapGesture {
                                selectedMovie = movie
                                dismiss()
                            }
                    }
                    .searchable(text: $searchText, prompt: "映画を検索")
                }
            }
            .navigationTitle("映画を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "film")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("映画がありません")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("先にサンプルデータを作成するか、\n映画を追加してください")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func movieSelectionRow(_ movie: Movie) -> some View {
        HStack {
            AsyncImage(url: posterURL(for: movie)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 50, height: 75)
            .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if let year = movie.releaseYear {
                    Text(year)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !movie.genreText.isEmpty {
                    Text(movie.genreText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if movie.totalViewings > 0 {
                    Text("鑑賞回数: \(movie.totalViewings)回")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func posterURL(for movie: Movie) -> URL? {
        guard let posterPath = movie.posterURL else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w154\(posterPath)")
    }
}

// MARK: - Convenience initializers

extension ViewingRecordFormView {
    // 新規作成用（映画指定）
    static func createMode(for movie: Movie) -> ViewingRecordFormView {
        ViewingRecordFormView(mode: .create(movie))
    }
    
    // 編集用
    static func editMode(record: ViewingRecord) -> ViewingRecordFormView {
        ViewingRecordFormView(mode: .edit(record))
    }
}

#Preview("新規作成") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Movie.self, ViewingRecord.self, configurations: config)
    
    let movie = Movie(tmdbId: 550, title: "ファイト・クラブ")
    container.mainContext.insert(movie)
    
    return ViewingRecordFormView.createMode(for: movie)
        .modelContainer(container)
}

#Preview("編集") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Movie.self, ViewingRecord.self, configurations: config)
    
    let movie = Movie(tmdbId: 550, title: "ファイト・クラブ")
    let record = ViewingRecord(viewingDate: Date(), rating: 5, notes: "素晴らしい映画")
    record.movie = movie
    
    container.mainContext.insert(movie)
    container.mainContext.insert(record)
    
    return ViewingRecordFormView.editMode(record: record)
        .modelContainer(container)
}