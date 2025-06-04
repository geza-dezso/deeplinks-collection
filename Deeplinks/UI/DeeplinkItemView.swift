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
    let group: DeeplinkGroup
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
                    editAction: {
                        viewModel.overlayState = .edit(deeplink, for: group)
                    }, deleteAction: {
                        viewModel.overlayState = .error(DeeplinkError(.comingSoon))
                    })
                #endif

            }
            .buttonStyle(
                DeeplinkItemStyle(isHighlighted: isHighlighted)
            )
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

    private var isHighlighted: Bool {
        #if os(iOS)
        viewModel.highlightedItemId == viewModel.itemIdFor(group: group, deeplink: deeplink)
        #else
        false
        #endif
    }
}
