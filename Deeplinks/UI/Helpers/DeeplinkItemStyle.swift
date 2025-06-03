//
//  DeeplinkItemStyle.swift
//  Deeplinks
//
//  Created by Geza Dezso on 08/04/2024.
//

import SwiftUI

struct DeeplinkItemStyle: ButtonStyle {

    var padding: CGFloat = 0
    let isHighlighted: Bool

    func makeBody(configuration: Configuration) -> some View {
        return DeeplinkItem(configuration: configuration, padding: padding, isHighlighted: isHighlighted)
    }

    struct DeeplinkItem: View {

        let configuration: ButtonStyle.Configuration
        let padding: CGFloat
        let isHighlighted: Bool

        #if os(iOS)

        var body: some View {
            configuration.label
                .padding(padding)
                .background(isHighlighted ? Color(red: 0.0, green: 0.30, blue: 0.40) : Color.black)
                .cornerRadius(4)
        }

        #else

        @Environment(\.isFocused) var isFocused: Bool
        var body: some View {
            configuration.label
                .padding(padding)
                .background(isFocused ? Color.darkGray : Color.black)
                .cornerRadius(8)
                .scaleEffect(isFocused ? 1.01 : 1.0)
                .animation(.easeInOut, value: isFocused)
        }

        #endif
    }
}
