//
//  ViewingRecordDetailView.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import SwiftUI
import SwiftData

struct ViewingRecordDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let record: ViewingRecord
    
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Movie Header
                movieHeaderView
                
                // Record Details
                recordDetailsView
            }
        }
        .navigationTitle("鑑賞記録")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    
                    Button(role: .destructive) {
                        
                        showingEditView = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(Color.themeAccent)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            ViewingRecordFormView.editMode(record: record)
        }
        .alert("記録を削除", isPresented: $showingDeleteAlert) {
            Button("削除", role: .destructive) {
                deleteRecord()
            }
            Button("キャンセル", role: .cancel) { }
        } message: {
            Text("この鑑賞記録を削除しますか？この操作は取り消せません。")
        }
    }
    
    private var movieHeaderView: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Poster Image
                AsyncImage(url: posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 120, height: 180)
                .cornerRadius(12)
                .shadow(radius: 4)
                
                // Movie Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(record.movie?.title ?? "不明な映画")
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(3)
                    
                    if let year = record.movie?.releaseYear {
                        Text(year)
                            .font(.subheadline)
                            .foregroundColor(Color.themeTextSecondary)
                    }
                    
                    if let genres = record.movie?.genres, !genres.isEmpty {
                        Text(genres.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(Color.themeTextSecondary)
                            .lineLimit(2)
                    }
                    
                    if let director = record.movie?.director {
                        Text("監督: \(director)")
                            .font(.caption)
                            .foregroundColor(Color.themeTextSecondary)
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding()
            .background(Color.themeBackground)
        }
    }
    
    private var recordDetailsView: some View {
        VStack(spacing: 0) {
            // Rating and Date
            ratingAndDateSection
            
            // Additional Info
            additionalInfoSection
            
            // Notes
            if record.hasNotes {
                notesSection
            }
            
            // Movie Stats (if multiple viewings)
            if let movie = record.movie, movie.totalViewings > 1 {
                movieStatsSection
            }
        }
    }
    
    private var ratingAndDateSection: some View {
        VStack(spacing: 16) {
            // Rating
            VStack(spacing: 8) {
                Text("評価")
                    .font(.headline)
                
                HStack {
                    Text(record.ratingStars)
                        .font(.title)
                    
                    Text("\(record.rating)/5")
                        .font(.title2)
                        .foregroundColor(Color.themeTextSecondary)
                }
            }
            
            Divider()
            
            // Viewing Date
            VStack(spacing: 4) {
                Text("鑑賞日")
                    .font(.headline)
                
                Text(record.fullFormattedDate)
                    .font(.title3)
                    .foregroundColor(Color.themeTextSecondary)
            }
            
            // Rewatch Badge
            if record.isRewatch {
                Text("再鑑賞")
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.themeSecondaryBackground)
    }
    
    private var additionalInfoSection: some View {
        VStack(spacing: 0) {
            if let location = record.location, !location.isEmpty {
                detailRow(title: "鑑賞場所", value: location, icon: "location")
            }
            
            if let watchedWith = record.watchedWith, !watchedWith.isEmpty {
                detailRow(title: "同伴者", value: watchedWith, icon: "person.2")
            }
            
            detailRow(title: "鑑賞回数", value: "\(record.viewingCount)回目", icon: "number")
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                Text("メモ・感想")
                    .font(.headline)
                
                Spacer()
            }
            
            Text(record.notes ?? "")
                .font(.body)
                .padding()
                .background(Color.themeTertiaryBackground)
                .cornerRadius(8)
        }
        .padding()
        .background(Color.themeBackground)
    }
    
    private var movieStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                Text("この映画の統計")
                    .font(.headline)
                
                Spacer()
            }
            
            if let movie = record.movie {
                VStack(spacing: 8) {
                    statsRow(title: "総鑑賞回数", value: "\(movie.totalViewings)回")
                    
                    if let avgRating = movie.averageRating {
                        statsRow(title: "平均評価", value: String(format: "%.1f/5", avgRating))
                    }
                    
                    if let lastViewing = movie.lastViewingDate {
                        statsRow(title: "最後の鑑賞", value: formatDate(lastViewing))
                    }
                }
                .padding()
                .background(Color.themeTertiaryBackground)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.themeBackground)
    }
    
    private func detailRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.themeTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color.themeBackground)
    }
    
    private func statsRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.themeTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
    
    private var posterURL: URL? {
        guard let posterPath = record.movie?.posterURL else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)")
    }
    
    private func deleteRecord() {
        ViewingRecordService.deleteViewingRecord(record, in: modelContext)
        dismiss()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Movie.self, ViewingRecord.self, configurations: config)
    
    // Create sample data
    let movie = Movie(tmdbId: 550, title: "ファイト・クラブ", posterURL: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg")
    let record = ViewingRecord(viewingDate: Date(), rating: 5, notes: "素晴らしい映画でした！", location: "TOHOシネマズ", watchedWith: "友人と")
    record.movie = movie
    
    container.mainContext.insert(movie)
    container.mainContext.insert(record)
    
    return NavigationStack {
        ViewingRecordDetailView(record: record)
    }
    .modelContainer(container)
    
}
