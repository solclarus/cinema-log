//
//  SampleDataManager.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import Foundation
import SwiftData

class SampleDataManager {
    
    static func createSampleData(in context: ModelContext) {
        // 既存のデータを確認
        let movieDescriptor = FetchDescriptor<Movie>()
        do {
            let existingMovies = try context.fetch(movieDescriptor)
            if !existingMovies.isEmpty {
                print("Sample data already exists")
                return
            }
        } catch {
            print("Error checking existing data: \(error)")
        }
        
        // サンプル映画データを作成
        let sampleMovies = createSampleMovies()
        
        // 映画をコンテキストに追加
        for movie in sampleMovies {
            context.insert(movie)
        }
        
        // サンプル鑑賞記録を作成
        createSampleViewingRecords(for: sampleMovies, in: context)
        
        // データを保存
        do {
            try context.save()
            print("Sample data created successfully")
        } catch {
            print("Failed to save sample data: \(error)")
        }
    }
    
    private static func createSampleMovies() -> [Movie] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return [
            Movie(
                tmdbId: 550,
                title: "ファイト・クラブ",
                posterURL: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
                releaseDate: dateFormatter.date(from: "1999-10-15"),
                overview: "不眠症に悩む男性が謎の男タイラー・ダーデンと出会い、地下格闘クラブを始める話。",
                genres: ["ドラマ", "スリラー"],
                director: "デヴィッド・フィンチャー",
                cast: ["ブラッド・ピット", "エドワード・ノートン", "ヘレナ・ボナム・カーター"]
            ),
            Movie(
                tmdbId: 13,
                title: "フォレスト・ガンプ/一期一会",
                posterURL: "/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg",
                releaseDate: dateFormatter.date(from: "1994-06-23"),
                overview: "知的障害を持つ男性フォレスト・ガンプの波乱万丈な人生を描いた感動作。",
                genres: ["ドラマ", "ロマンス"],
                director: "ロバート・ゼメキス",
                cast: ["トム・ハンクス", "ロビン・ライト", "ゲイリー・シニーズ"]
            ),
            Movie(
                tmdbId: 278,
                title: "ショーシャンクの空に",
                posterURL: "/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg",
                releaseDate: dateFormatter.date(from: "1994-09-23"),
                overview: "無実の罪で投獄された銀行員が、希望を失わず刑務所で友情を育む物語。",
                genres: ["ドラマ", "犯罪"],
                director: "フランク・ダラボン",
                cast: ["ティム・ロビンス", "モーガン・フリーマン", "ボブ・ガントン"]
            ),
            Movie(
                tmdbId: 238,
                title: "ゴッドファーザー",
                posterURL: "/3bhkrj58Vtu7enYsRolD1fZdja1.jpg",
                releaseDate: dateFormatter.date(from: "1972-03-14"),
                overview: "イタリア系アメリカ人マフィアのコルレオーネ・ファミリーの物語。",
                genres: ["ドラマ", "犯罪"],
                director: "フランシス・フォード・コッポラ",
                cast: ["マーロン・ブランド", "アル・パチーノ", "ジェームズ・カーン"]
            ),
            Movie(
                tmdbId: 424,
                title: "シンドラーのリスト",
                posterURL: "/sF1U4EUQS8YHUYjNl3pMGNIQyr0.jpg",
                releaseDate: dateFormatter.date(from: "1993-11-30"),
                overview: "第二次世界大戦中にユダヤ人を救ったオスカー・シンドラーの実話。",
                genres: ["ドラマ", "歴史"],
                director: "スティーヴン・スピルバーグ",
                cast: ["リーアム・ニーソン", "ベン・キングズレー", "レイフ・ファインズ"]
            ),
            Movie(
                tmdbId: 680,
                title: "パルプ・フィクション",
                posterURL: "/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg",
                releaseDate: dateFormatter.date(from: "1994-09-10"),
                overview: "ロサンゼルスの裏社会を舞台にした3つの物語が交錯するクライム映画。",
                genres: ["犯罪", "ドラマ"],
                director: "クエンティン・タランティーノ",
                cast: ["ジョン・トラボルタ", "サミュエル・L・ジャクソン", "ユマ・サーマン"]
            ),
            Movie(
                tmdbId: 155,
                title: "ダークナイト",
                posterURL: "/qJ2tW6WMUDux911r6m7haRef0WH.jpg",
                releaseDate: dateFormatter.date(from: "2008-07-16"),
                overview: "バットマンが狂気のジョーカーと対決する、ダークで重厚なスーパーヒーロー映画。",
                genres: ["アクション", "犯罪", "ドラマ"],
                director: "クリストファー・ノーラン",
                cast: ["クリスチャン・ベール", "ヒース・レジャー", "アーロン・エッカート"]
            ),
            Movie(
                tmdbId: 129,
                title: "千と千尋の神隠し",
                posterURL: "/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg",
                releaseDate: dateFormatter.date(from: "2001-07-20"),
                overview: "神々の世界に迷い込んだ少女千尋の冒険を描いたスタジオジブリの名作。",
                genres: ["アニメーション", "ファンタジー", "ファミリー"],
                director: "宮崎駿",
                cast: ["柊瑠美", "入野自由", "夏木マリ"]
            )
        ]
    }
    
    private static func createSampleViewingRecords(for movies: [Movie], in context: ModelContext) {
        let calendar = Calendar.current
        let now = Date()
        
        // 各映画に対してランダムな鑑賞記録を作成
        for (index, movie) in movies.enumerated() {
            let recordCount = Int.random(in: 1...3) // 1-3回の鑑賞記録
            
            for i in 0..<recordCount {
                let daysBack = Int.random(in: 1...30) // 過去1年以内
                let viewingDate = calendar.date(byAdding: .day, value: -daysBack, to: now) ?? now
                
                let rating = Int.random(in: 3...5) // 3-5星の評価
                
                let sampleNotes = [
                    "とても感動的な映画でした。何度でも見たい作品です。",
                    "素晴らしい演技と映像美に圧倒されました。",
                    "ストーリーが予想以上に良くて満足でした。",
                    "友人と一緒に見て、とても楽しい時間を過ごせました。",
                    "久しぶりに見返しましたが、やはり名作ですね。",
                    "映画館の大画面で見る価値がある作品でした。"
                ]
                
                let sampleLocations = [
                    "TOHOシネマズ",
                    "イオンシネマ",
                    "自宅",
                    "友人宅",
                    "新宿ピカデリー",
                    "渋谷TSUTAYA"
                ]
                
                let sampleCompanions = [
                    "一人で",
                    "友人と",
                    "家族と",
                    "恋人と",
                    "同僚と"
                ]
                
                let notes = Bool.random() ? sampleNotes.randomElement() : nil
                let location = Bool.random() ? sampleLocations.randomElement() : nil
                let watchedWith = Bool.random() ? sampleCompanions.randomElement() : nil
                
                _ = ViewingRecordService.createViewingRecord(
                    for: movie,
                    viewingDate: viewingDate,
                    rating: rating,
                    notes: notes,
                    location: location,
                    watchedWith: watchedWith,
                    in: context
                )
            }
        }
    }
    
    // 追加のサンプルデータ作成メソッド
    static func addMoreSampleRecords(in context: ModelContext) {
        let movieDescriptor = FetchDescriptor<Movie>()
        do {
            let existingMovies = try context.fetch(movieDescriptor)
            if existingMovies.isEmpty {
                print("No movies found. Please create sample movies first.")
                return
            }
            
            // 既存の映画に追加の鑑賞記録を作成
            let calendar = Calendar.current
            let now = Date()
            
            for movie in existingMovies.prefix(3) { // 最初の3つの映画に追加記録
                let viewingDate = calendar.date(byAdding: .day, value: -Int.random(in: 1...30), to: now) ?? now
                let rating = Int.random(in: 4...5)
                
                _ = ViewingRecordService.createViewingRecord(
                    for: movie,
                    viewingDate: viewingDate,
                    rating: rating,
                    notes: "追加の鑑賞記録です。再度見ても面白い！",
                    location: "自宅",
                    watchedWith: "一人で",
                    in: context
                )
            }
            
            try context.save()
            print("Additional sample records created")
        } catch {
            print("Failed to add more sample records: \(error)")
        }
    }
    
    // サンプルデータ削除メソッド
    static func clearAllSampleData(in context: ModelContext) {
        do {
            // すべての鑑賞記録を削除
            let recordDescriptor = FetchDescriptor<ViewingRecord>()
            let records = try context.fetch(recordDescriptor)
            for record in records {
                context.delete(record)
            }
            
            // すべての映画を削除
            let movieDescriptor = FetchDescriptor<Movie>()
            let movies = try context.fetch(movieDescriptor)
            for movie in movies {
                context.delete(movie)
            }
            
            try context.save()
            print("All sample data cleared")
        } catch {
            print("Failed to clear sample data: \(error)")
        }
    }
}
