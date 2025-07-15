//
//  RecordsView.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import SwiftData
import SwiftUI

struct RecordsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ViewingRecord.viewingDate, order: .reverse) private
        var viewingRecords: [ViewingRecord]

    @State private var selectedDisplayMode: DisplayMode = .list

    enum DisplayMode: String, CaseIterable {
        case list = "リスト"
        case calendar = "カレンダー"
        case poster = "ポスター"

        var systemImage: String {
            switch self {
            case .list: return "list.bullet"
            case .calendar: return "calendar"
            case .poster: return "photo.on.rectangle"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Content based on selected mode
                if viewingRecords.isEmpty {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .navigationTitle("鑑賞記録")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("サンプルデータ") {
                        SampleDataManager.createSampleData(in: modelContext)
                    }
                    .font(.caption)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 8) {
                        ForEach(DisplayMode.allCases, id: \.self) { mode in
                            Button {
                                selectedDisplayMode = mode
                            } label: {
                                Image(systemName: mode.systemImage)
                                    .foregroundColor(selectedDisplayMode == mode ? .blue : .secondary)
                                    .font(.headline)
                            }
                        }
                    }
                }
            }
        }
    }


    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "film")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("鑑賞記録がありません")
                .font(.title2)
                .foregroundColor(.secondary)

            Text("映画を見たら、映画詳細画面から記録を追加してみましょう")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedDisplayMode {
        case .list:
            ViewingRecordListView()
        case .calendar:
            ViewingRecordCalendarView()
        case .poster:
            ViewingRecordPosterView()
        }
    }

}


#Preview {
    RecordsView()
}
