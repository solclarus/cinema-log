//
//  SettingsView.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("外観") {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(Color.themeAccent)
                            .frame(width: 20, height: 20)
                        
                        Text("ダークモード")
                            .foregroundColor(Color.themeTextPrimary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $isDarkMode)
                            .toggleStyle(SwitchToggleStyle())
                    }
                }
                
                Section("アプリについて") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(Color.themeAccent)
                            .frame(width: 20, height: 20)
                        
                        Text("バージョン")
                            .foregroundColor(Color.themeTextPrimary)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(Color.themeTextSecondary)
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(Color.themeRed)
                            .frame(width: 20, height: 20)
                        
                        Text("開発者")
                            .foregroundColor(Color.themeTextPrimary)
                        
                        Spacer()
                        
                        Text("CinemaLog Team")
                            .foregroundColor(Color.themeTextSecondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("その他") {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(Color.themeAccent)
                            .frame(width: 20, height: 20)
                        
                        Text("ヘルプ")
                            .foregroundColor(Color.themeTextPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.themeTextTertiary)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(Color.themeAccent)
                            .frame(width: 20, height: 20)
                        
                        Text("フィードバック")
                            .foregroundColor(Color.themeTextPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.themeTextTertiary)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
            }
            .background(Color.themeGroupedBackground)
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView()
}
