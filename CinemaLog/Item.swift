//
//  Item.swift
//  CinemaLog
//
//  Created by Yosuke Osako on 2025/07/13.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
