//
//  SettingsView.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Settings")
                    .foregroundColor(.primary)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "gear")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
