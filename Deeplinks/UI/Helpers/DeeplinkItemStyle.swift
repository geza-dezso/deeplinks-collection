//
//  DeeplinkItemStyle.swift
//  Deeplinks
//
//  Created by Geza Dezso on 08/04/2024.
//

import SwiftUI

struct DeeplinkItemStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        return DeeplinkItem(configuration: configuration)
    }

    struct DeeplinkItem: View {

        private let padding: CGFloat = isTV ? 16 : isIPad ? 12 : 8

        let configuration: ButtonStyle.Configuration

        #if os(iOS)

        var body: some View {
            configuration.label
                .padding(padding)
                .background(Color.black)
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
