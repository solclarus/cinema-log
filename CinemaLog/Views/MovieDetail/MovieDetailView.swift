//
//  MovieDetailView.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import SwiftData
import SwiftUI

struct MovieDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    let movie: Movie
    
    @State private var showingAddRecord = false
    @State private var showingWatchlistAlert = false
    
    private var isInWatchlist: Bool {
        // ウォッチリスト判定（後で実装）
        false
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with poster and basic info
                movieHeaderView
                
                // Movie details
                movieDetailsView
                
                // Viewing records section
                viewingRecordsSection
            }
        }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // Watchlist button
                    Button {
                        showingWatchlistAlert = true
                    } label: {
                        Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                            .foregroundColor(Color.themeOrange)
                    }
                    
                    // Add viewing record button
                    Button {
                        showingAddRecord = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.themeAccent)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddRecord) {
            ViewingRecordFormView.createMode(for: movie)
        }
        .alert("ウォッチリスト", isPresented: $showingWatchlistAlert) {
            Button("追加") {
                // ウォッチリスト追加処理（後で実装）
            }
            Button("キャンセル", role: .cancel) { }
        } message: {
            Text("この映画をウォッチリストに追加しますか？")
        }
    }
    
    private var movieHeaderView: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Poster
                AsyncImage(url: posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 140, height: 210)
                .cornerRadius(12)
                .shadow(radius: 8)
                
                // Movie info
                VStack(alignment: .leading, spacing: 8) {
                    Text(movie.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(3)
                    
                    if let year = movie.releaseYear {
                        Text(year)
                            .font(.subheadline)
                            .foregroundColor(Color.themeTextSecondary)
                    }
                    
                    if let genres = movie.genres, !genres.isEmpty {
                        Text(genres.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(Color.themeTextSecondary)
                            .lineLimit(2)
                    }
                    
                    if let director = movie.director {
                        Text("監督: \(director)")
                            .font(.caption)
                            .foregroundColor(Color.themeTextSecondary)
                    }
                    
                    // Statistics if viewed
                    if movie.totalViewings > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("鑑賞回数:")
                                    .font(.caption)
                                    .foregroundColor(Color.themeTextSecondary)
                                Text("\(movie.totalViewings)回")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            if let avgRating = movie.averageRating {
                                HStack {
                                    Text("平均評価:")
                                        .font(.caption)
                                        .foregroundColor(Color.themeTextSecondary)
                                    Text(String(format: "%.1f", avgRating))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Text("★")
                                        .font(.caption)
                                        .foregroundColor(Color.themeYellow)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color.themeBackground)
    }
    
    private var movieDetailsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let overview = movie.overview, !overview.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("あらすじ")
                        .font(.headline)
                    
                    Text(overview)
                        .font(.body)
                        .lineSpacing(2)
                }
                .padding()
                .background(Color.themeSecondaryBackground)
            }
            
            if let cast = movie.cast, !cast.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("キャスト")
                        .font(.headline)
                    
                    Text(cast.joined(separator: ", "))
                        .font(.body)
                        .foregroundColor(Color.themeTextSecondary)
                }
                .padding()
                .background(Color.themeSecondaryBackground)
            }
        }
    }
    
    private var viewingRecordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("鑑賞記録")
                    .font(.headline)
                
                Spacer()
                
                if movie.totalViewings > 0 {
                    Text("\(movie.totalViewings)件")
                        .font(.caption)
                        .foregroundColor(Color.themeTextSecondary)
                }
            }
            .padding(.horizontal)
            
            if movie.viewingRecords.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "film")
                        .font(.system(size: 40))
                        .foregroundColor(Color.themeTextSecondary)
                    
                    Text("まだ鑑賞記録がありません")
                        .font(.subheadline)
                        .foregroundColor(Color.themeTextSecondary)
                    
                    Button("記録を追加") {
                        showingAddRecord = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color.themeTertiaryBackground)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(movie.viewingRecords.sorted(by: { $0.viewingDate > $1.viewingDate })) { record in
                        NavigationLink(destination: ViewingRecordDetailView(record: record)) {
                            ViewingRecordSummaryRow(record: record)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            
            // Add new record button
            Button {
                showingAddRecord = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("新しい記録を追加")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.themeAccent)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.themeBackground)
    }
    
    private var posterURL: URL? {
        guard let posterPath = movie.posterURL else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)")
    }
}

struct ViewingRecordSummaryRow: View {
    let record: ViewingRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.formattedDate)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(record.ratingStars)
                        .font(.caption)
                    
                    if record.isRewatch {
                        Text("再鑑賞")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
                
                if let notes = record.shortNotes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(Color.themeTextSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color.themeTextSecondary)
        }
        .padding()
        .background(Color.themeTertiaryBackground)
        .cornerRadius(8)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Movie.self, ViewingRecord.self, configurations: config)
    
    let movie = Movie(
        tmdbId: 550,
        title: "ファイト・クラブ",
        posterURL: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
        releaseDate: Date(),
        overview: "不眠症に悩む男性が謎の男タイラー・ダーデンと出会い、地下格闘クラブを始める話。",
        genres: ["ドラマ", "スリラー"],
        director: "デヴィッド・フィンチャー",
        cast: ["ブラッド・ピット", "エドワード・ノートン", "ヘレナ・ボナム・カーター"]
    )
    
    container.mainContext.insert(movie)
    
    return NavigationStack {
        MovieDetailView(movie: movie)
    }
    .modelContainer(container)
    
}
