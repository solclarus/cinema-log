//
//  ThemeManager.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/15.
//

import SwiftUI

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