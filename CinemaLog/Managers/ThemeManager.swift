//
//  ThemeManager.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/15.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false {
        didSet {
            print("ThemeManager: isDarkMode changed to \(isDarkMode)")
            userDefaults.set(isDarkMode, forKey: darkModeKey)
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let darkModeKey = "isDarkMode"
    
    init() {
        // Load saved theme preference without triggering didSet
        let savedValue = userDefaults.bool(forKey: darkModeKey)
        print("ThemeManager: Loading saved value: \(savedValue)")
        _isDarkMode = Published(initialValue: savedValue)
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
    
    func setTheme(_ isDark: Bool) {
        isDarkMode = isDark
    }
    
    var colorScheme: ColorScheme? {
        return isDarkMode ? .dark : .light
    }
}

// MARK: - Color Theme Extensions

extension Color {
    // Background Colors
    static let themeBackground = Color(UIColor.systemBackground)
    static let themeSecondaryBackground = Color(UIColor.secondarySystemBackground)
    static let themeTertiaryBackground = Color(UIColor.tertiarySystemBackground)
    static let themeGroupedBackground = Color(UIColor.systemGroupedBackground)
    static let themeGroupedSecondaryBackground = Color(UIColor.secondarySystemGroupedBackground)
    
    // Text Colors
    static let themeTextPrimary = Color(UIColor.label)
    static let themeTextSecondary = Color(UIColor.secondaryLabel)
    static let themeTextTertiary = Color(UIColor.tertiaryLabel)
    
    // Accent Colors
    static let themeAccent = Color.accentColor
    static let themeBlue = Color.blue
    static let themeOrange = Color.orange
    static let themeGreen = Color.green
    static let themeRed = Color.red
    static let themeYellow = Color.yellow
    
    // Card Colors
    static let themeCardBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let themeCardBorder = Color(UIColor.separator)
    
    // System Colors
    static let themeSeparator = Color(UIColor.separator)
    static let themeOpaqueSeparator = Color(UIColor.opaqueSeparator)
}