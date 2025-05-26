//
//  Color+Helpers.swift
//  Deeplinks
//
//  Created by Geza Dezso on 11/04/2024.
//

import SwiftUI

extension Color {
    static let darkGray = Color(red: 0.33, green: 0.33, blue: 0.33)
    static let lightGray = Color(red: 0.66, green: 0.66, blue: 0.66)

    static let primaryText = Color.white
    static let secondaryText = Color.lightGray
    static let placeholderText = Color.darkGray

    static let mainBackground = Color(red: 0.0, green: 0.15, blue: 0.20)
    static let buttonBackground = Color(red: 0.0, green: 0.1, blue: 0.13)
    static let itemBackground = Color.white.opacity(0.1)
    static let focusedItemBackground = Color.white.opacity(0.2)
}
