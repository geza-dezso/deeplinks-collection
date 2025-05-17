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
                .padding(padding)

                #if os(iOS)
                .addSwipeAction(menu: .slided) {
                    Leading {
                        Button {
                            // edit action
                            print("Edit")
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(.white)
                                .frame(width: 60, alignment: .center)
                                .frame(maxHeight: .infinity)
                                .background(Color.itemButtonBackground)
                        }
                        .padding(.trailing, padding)
                    }
                    Trailing {
                        Button {
                            // delete action
                            print("Delete")
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                                .frame(width: 60, alignment: .center)
                                .frame(maxHeight: .infinity)
                                .background(Color.itemButtonBackground)
                        }
                        .padding(.leading, padding)
                    }
                }
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
