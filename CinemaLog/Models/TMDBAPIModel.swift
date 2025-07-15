//
//  TMDBModels.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import Foundation

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

// MARK: - Genre Mapping

struct TMDBGenreMapping {
    static let genres: [Int: String] = [
        28: "アクション",
        12: "アドベンチャー",
        16: "アニメーション",
        35: "コメディ",
        80: "犯罪",
        99: "ドキュメンタリー",
        18: "ドラマ",
        10751: "ファミリー",
        14: "ファンタジー",
        36: "歴史",
        27: "ホラー",
        10402: "音楽",
        9648: "ミステリー",
        10749: "ロマンス",
        878: "SF",
        10770: "テレビ映画",
        53: "スリラー",
        10752: "戦争",
        37: "西部劇"
    ]
    
    static let englishGenres: [Int: String] = [
        28: "Action",
        12: "Adventure",
        16: "Animation",
        35: "Comedy",
        80: "Crime",
        99: "Documentary",
        18: "Drama",
        10751: "Family",
        14: "Fantasy",
        36: "History",
        27: "Horror",
        10402: "Music",
        9648: "Mystery",
        10749: "Romance",
        878: "Science Fiction",
        10770: "TV Movie",
        53: "Thriller",
        10752: "War",
        37: "Western"
    ]
    
    static func getGenreName(for id: Int, language: String = "ja") -> String {
        if language == "en" {
            return englishGenres[id] ?? "Unknown"
        }
        return genres[id] ?? "不明"
    }
}

// MARK: - Movie Model Integration

extension TMDBMovie {
    func toSwiftDataMovie() -> Movie {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let releaseDate = releaseDate.flatMap { dateFormatter.date(from: $0) }
        
        let genreNames = genreIds.map { TMDBGenreMapping.getGenreName(for: $0) }
        
        return Movie(
            tmdbId: id,
            title: title,
            posterURL: posterPath,
            releaseDate: releaseDate,
            overview: overview.isEmpty ? nil : overview,
            genres: genreNames.isEmpty ? nil : genreNames,
            director: nil,
            cast: nil
        )
    }
    
    var formattedReleaseYear: String? {
        guard let releaseDate = releaseDate else { return nil }
        let year = String(releaseDate.prefix(4))
        return year
    }
    
    var formattedGenres: String {
        let genreNames = genreIds.map { TMDBGenreMapping.getGenreName(for: $0) }
        return genreNames.joined(separator: ", ")
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
    
    var formattedRuntime: String? {
        guard let runtime = runtime else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        return "\(hours)時間\(minutes)分"
    }
    
    var formattedReleaseYear: String? {
        guard let releaseDate = releaseDate else { return nil }
        let year = String(releaseDate.prefix(4))
        return year
    }
}