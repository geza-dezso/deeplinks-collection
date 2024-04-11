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

        var body: some View {
            configuration.label
                .font(primary)
                .padding(8)
                .foregroundColor(isEnabled ? .white : Color(red: 0.33, green: 0.33, blue: 0.33))
                .background(isEnabled ? Color.white.opacity(0.1) : .clear)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isEnabled ? .gray : Color(red: 0.33, green: 0.33, blue: 0.33), lineWidth: 1)
                )
        }
    }
}
