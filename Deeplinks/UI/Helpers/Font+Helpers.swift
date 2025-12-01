//
//  Font+Helpers.swift
//  Deeplinks
//
//  Created by Geza Dezso on 09/04/2024.
//

import SwiftUI

var headline: Font {
    isTV ? .system(.title2) : isIPad ? .system(size: 32) : .system(size: 24)
}

var primary: Font {
    isTV ? .system(.headline) : isIPad ? .system(size: 22) : .system(size: 16)
}

var secondary: Font {
    isTV ? .system(.body) : isIPad ? .system(size: 16) : .system(size: 14)
}
