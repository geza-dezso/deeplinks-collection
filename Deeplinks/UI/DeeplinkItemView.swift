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
            .buttonStyle(DeeplinkItemStyle())
        }
    }

    private func title(_ text: String) -> some View {
        Text(text)
            .font(isTV ? .system(.headline) : isIPad ? .system(size: 22) : .system(size: 16))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
    }

    private func subtitle(_ text: String) -> some View {
        Text(text)
            .font(isTV ? .system(.body) : isIPad ? .system(size: 16) : .system(size: 12))
            .foregroundColor(.gray)
            .multilineTextAlignment(.leading)
    }
}
