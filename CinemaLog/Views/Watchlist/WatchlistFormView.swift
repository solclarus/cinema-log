//
//  WatchlistFormView.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/15.
//

import SwiftUI
import SwiftData

struct WatchlistFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let movie: Movie
    
    @State private var selectedPriority: WatchlistPriority = .medium
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Movie info
                    HStack(spacing: 12) {
                        AsyncImage(url: posterURL) { image in
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
                        .frame(width: 60, height: 90)
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(movie.title)
                                .font(.headline)
                                .foregroundColor(Color.themeTextPrimary)
                                .lineLimit(2)
                            
                            if let year = movie.releaseYear {
                                Text(year)
                                    .font(.subheadline)
                                    .foregroundColor(Color.themeTextSecondary)
                            }
                            
                            if let genres = movie.genres, !genres.isEmpty {
                                Text(genres.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundColor(Color.themeTextSecondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    // Priority selection
                    HStack {
                        Image(systemName: "flag.fill")
                            .foregroundColor(priorityColor(for: selectedPriority))
                        
                        Text("優先度")
                            .foregroundColor(Color.themeTextPrimary)
                        
                        Spacer()
                        
                        Picker("優先度", selection: $selectedPriority) {
                            ForEach(WatchlistPriority.allCases, id: \.self) { priority in
                                Text(priority.localizedTitle)
                                    .tag(priority)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                    }
                    .padding(.vertical, 4)
                    
                }
            }
            .navigationTitle("ウォッチリストに追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        addToWatchlist()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .alert("追加完了", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("「\(movie.title)」をウォッチリストに追加しました")
        }
    }
    
    private func addToWatchlist() {
        WatchlistService.addToWatchlist(
            movie: movie,
            priority: selectedPriority,
            in: modelContext
        )
        showingSuccessAlert = true
    }
    
    private func priorityColor(for priority: WatchlistPriority) -> Color {
        switch priority {
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
        return URL(string: "https://image.tmdb.org/t/p/w185\(posterPath)")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Movie.self, ViewingRecord.self, WatchlistItem.self, configurations: config)
    
    let movie = Movie(
        tmdbId: 550,
        title: "ファイト・クラブ",
        posterURL: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
        releaseDate: Date(),
        genres: ["ドラマ", "スリラー"]
    )
    
    return WatchlistFormView(movie: movie)
        .modelContainer(container)
}