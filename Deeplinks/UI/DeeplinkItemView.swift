//
//  DeeplinkItemView.swift
//  Deeplinks
//
//  Created by Geza Dezso on 08/04/2024.
//

import SwiftUI

struct DeeplinkItemView: View {

    let title: String
    let link: String
    let padding: CGFloat

    var body: some View {
        HStack {
            Link(destination: URL(string: link)!) {
                VStack(spacing: 4) {
                    HStack {
                        title(title)
                        Spacer()
                    }
                    HStack {
                        subtitle(link)
                        Spacer()
                    }
                }
            }
            .buttonStyle(DeeplinkItemStyle(padding: padding))
        }
        .listRowBackground(Color.clear)
    }

    private func title(_ text: String) -> some View {
        Text(text)
            .font(primary)
            .foregroundColor(.primaryText)
            .multilineTextAlignment(.leading)
    }

    private func subtitle(_ text: String) -> some View {
        Text(text)
            .font(secondary)
            .foregroundColor(.secondaryText)
            .multilineTextAlignment(.leading)
    }
}
