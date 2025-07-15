//
//  ViewingRecordPosterView.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import SwiftUI
import SwiftData

struct ViewingRecordPosterView: View {
    @Query(sort: \ViewingRecord.viewingDate, order: .reverse) private var viewingRecords: [ViewingRecord]
    
    @State private var selectedSortOption: SortOption = .date
    @State private var showingSortSheet = false
    
    enum SortOption: String, CaseIterable {
        case date = "鑑賞日"
        case rating = "評価"
        case title = "タイトル"
        
        var systemImage: String {
            switch self {
            case .date: return "calendar"
            case .rating: return "star"
            case .title: return "textformat.abc"
            }
        }
    }
    
    private var sortedRecords: [ViewingRecord] {
        switch selectedSortOption {
        case .date:
            return viewingRecords.sorted { $0.viewingDate > $1.viewingDate }
        case .rating:
            return viewingRecords.sorted { $0.rating > $1.rating }
        case .title:
            return viewingRecords.sorted { 
                ($0.movie?.title ?? "") < ($1.movie?.title ?? "") 
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Sort options header
            sortHeader
            
            // Poster grid
            posterGrid
        }
    }
    
    private var sortHeader: some View {
        HStack {
            Text("並び順:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button {
                showingSortSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: selectedSortOption.systemImage)
                        .font(.caption)
                    Text(selectedSortOption.rawValue)
                        .font(.subheadline)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text("\(viewingRecords.count)件")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .confirmationDialog("並び順を選択", isPresented: $showingSortSheet) {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    selectedSortOption = option
                } label: {
                    Label(option.rawValue, systemImage: option.systemImage)
                }
            }
        }
    }
    
    private var posterGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(sortedRecords) { record in
                    NavigationLink(destination: ViewingRecordDetailView(record: record)) {
                        PosterGridItem(record: record)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

fileprivate struct PosterGridItem: View {
    let record: ViewingRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster with overlay info
            ZStack {
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
                                    .font(.title)
                                    .foregroundColor(.gray)
                                Text("ポスター")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                }
                .frame(height: 140)
                .clipped()
                
                // Overlay with rating and rewatch indicator
                VStack {
                    HStack {
                        Spacer()
                        
                        if record.isRewatch {
                            Text("再")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(4)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= record.rating ? "star.fill" : "star")
                                    .font(.caption2)
                                    .foregroundColor(star <= record.rating ? .yellow : .gray.opacity(0.6))
                            }
                        }
                        .padding(6)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(6)
                        
                        Spacer()
                        
                        Text(record.shortFormattedDate)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                .padding(8)
            }
            .cornerRadius(10)
            .shadow(radius: 3)
            
            // Movie title
            Text(record.movie?.title ?? "不明な映画")
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
    }
    
    private var posterURL: URL? {
        guard let posterPath = record.movie?.posterURL else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Movie.self, ViewingRecord.self, configurations: config)
    
    let movies = [
        Movie(tmdbId: 550, title: "ファイト・クラブ", posterURL: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg"),
        Movie(tmdbId: 13, title: "フォレスト・ガンプ", posterURL: "/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg"),
        Movie(tmdbId: 278, title: "ショーシャンクの空に", posterURL: "/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg")
    ]
    
    for (index, movie) in movies.enumerated() {
        let record = ViewingRecord(viewingDate: Date().addingTimeInterval(-Double(index * 86400)), rating: 5 - index)
        record.movie = movie
        container.mainContext.insert(movie)
        container.mainContext.insert(record)
    }
    
    return NavigationStack {
        ViewingRecordPosterView()
    }
    .modelContainer(container)
}