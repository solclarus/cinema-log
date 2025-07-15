//
//  ViewingRecordListView.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import SwiftUI
import SwiftData

struct ViewingRecordListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ViewingRecord.viewingDate, order: .reverse) private var viewingRecords: [ViewingRecord]
    
    var body: some View {
        List {
            ForEach(viewingRecords) { record in
                NavigationLink(
                    destination: ViewingRecordDetailView(record: record)
                ) {
                    ViewingRecordRow(record: record)
                }
                .swipeActions(edge: .trailing) {
                    Button("削除", role: .destructive) {
                        deleteRecord(record)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func deleteRecord(_ record: ViewingRecord) {
        ViewingRecordService.deleteViewingRecord(record, in: modelContext)
    }
}

fileprivate struct ViewingRecordRow: View {
    let record: ViewingRecord
    
    var body: some View {
        HStack {
            AsyncImage(url: posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 90)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.movie?.title ?? "不明な映画")
                    .font(.headline)
                    .lineLimit(2)
                
                Text(record.formattedDate)
                    .font(.caption)
                    .foregroundColor(Color.themeTextSecondary)
                
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
        }
        .padding(.vertical, 4)
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
    let record = ViewingRecord(viewingDate: Date(), rating: 5, notes: "素晴らしい映画でした！")
    record.movie = movie
    
    container.mainContext.insert(movie)
    container.mainContext.insert(record)
    
    return NavigationStack {
        ViewingRecordListView()
    }
    .modelContainer(container)
    
}