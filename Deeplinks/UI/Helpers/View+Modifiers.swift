//
//  View+Modifiers.swift
//  Deeplinks
//
//  Created by Geza Dezso on 04/04/2024.
//

import SwiftUI

struct ScrollContentBackgroundViewModifier: ViewModifier {
    var visibility: Visibility

    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 16, *) {
            content
                .scrollContentBackground(visibility)
        } else {
            content
        }
        #else
        content
        #endif
    }
}

extension View {

    @ViewBuilder
    func contentBackground(_ visibility: Visibility) -> some View {
        self.modifier(ScrollContentBackgroundViewModifier(visibility: visibility))
    }
}
