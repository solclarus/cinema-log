//
//  ContentView.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Query private var movies: [Movie]

    var body: some View {
        TabView {
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "film")
                }
            
            RecordsView()
                .tabItem {
                    Label("Records", systemImage: "calendar")
                }
            
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.pie")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Movie.self, ViewingRecord.self, WatchlistItem.self, UserStreamingService.self], inMemory: true)
}
