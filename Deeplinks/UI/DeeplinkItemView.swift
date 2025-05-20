//
//  DeeplinkItemView.swift
//  Deeplinks
//
//  Created by Geza Dezso on 08/04/2024.
//

import SwiftUI
#if os(iOS)
import SwipeActions
#endif

struct DeeplinkItemView: View {
    #if os(iOS)
    @ObservedObject var viewModel: ContentViewModel
    @Binding var swipeState: SwipeState
    #endif

    let deeplink: Deeplink
    let padding: CGFloat

    var body: some View {
        HStack {
            Link(destination: URL(string: deeplink.url)!) {
                VStack(spacing: 4) {
                    HStack {
                        title(deeplink.title)
                        Spacer()
                    }
                    HStack {
                        subtitle(deeplink.url)
                        Spacer()
                    }
                }
                .padding(padding)

                #if os(iOS)
                .itemSwipeActions(
                    state: $swipeState,
                    horizontalPadding: padding,
                    editAction: {
                        viewModel.overlayState = .error(DeeplinkError(.comingSoon))
                    }, deleteAction: {
                        viewModel.overlayState = .error(DeeplinkError(.comingSoon))
                    })
                #endif

            }
            .buttonStyle(DeeplinkItemStyle())
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
