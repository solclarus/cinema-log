//
//  StatisticsView.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import SwiftData
import SwiftUI

struct StatisticsView: View {

    var body: some View {
        NavigationStack {
            VStack {
                Text("Statistics")
                    .foregroundColor(Color.themeTextPrimary)
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "chart.pie")
                        .foregroundColor(Color.themeAccent)
                }
            }
        }
    }
}

#Preview {
    StatisticsView()
}
