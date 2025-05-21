//
//  ActionButtonStyle.swift
//  Deeplinks
//
//  Created by Geza Dezso on 11/04/2024.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        return ActionButtonItem(configuration: configuration)
    }

    struct ActionButtonItem: View {
        @Environment(\.isEnabled) private var isEnabled

        let configuration: ButtonStyle.Configuration

        #if os(iOS)

        var body: some View {
            configuration.label
                .font(primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
                .foregroundColor(isEnabled ? .primaryText : .darkGray)
                .background(isEnabled ? Color.itemBackground : .clear)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isEnabled ? .gray : .darkGray, lineWidth: 1)
                )
        }

        #else

        @Environment(\.isFocused) var isFocused: Bool
        var body: some View {
            configuration.label
                .font(primary)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .foregroundColor(isEnabled ? .primaryText : .darkGray)
                .background(isFocused ? Color.focusedItemBackground : isEnabled ? Color.itemBackground : .clear)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isFocused ? .white : isEnabled ? .gray : .darkGray, lineWidth: 1)
                )
                .scaleEffect(isFocused ? 1.1 : 1.0)
                .animation(.easeInOut, value: isFocused)
        }

        #endif
    }
}
