//
//  Font+Helpers.swift
//  Deeplinks
//
//  Created by Geza Dezso on 09/04/2024.
//

import SwiftUI

var primary: Font {
    isTV ? .system(.headline) : isIPad ? .system(size: 22) : .system(size: 16)
}

var secondary: Font {
    isTV ? .system(.body) : isIPad ? .system(size: 16) : .system(size: 12)
}
