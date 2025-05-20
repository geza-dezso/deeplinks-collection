//
//  SwipeAction+Modifier.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2025. 05. 20..
//

import SwiftUI
import SwipeActions

public extension View {
    func itemSwipeActions(
        state: Binding<SwipeState> = .constant(.untouched),
        horizontalPadding: CGFloat,
        editActionHandler: @escaping () -> Void,
        deleteActionHandler: @escaping () -> Void
    ) -> some View {
        self.modifier(ItemSwipeActionsModifier(state: state, horizontalPadding: horizontalPadding, editActionHandler: editActionHandler, deleteActionHandler: deleteActionHandler))
    }
}

struct ItemSwipeActionsModifier: ViewModifier {
    var state: Binding<SwipeState> = .constant(.untouched)
    let horizontalPadding: CGFloat
    let editActionHandler: () -> Void
    let deleteActionHandler: () -> Void

    func body(content: Content) -> some View {
        content
            .addSwipeAction(menu: .slided, state: state) {
                Leading {
                    Button {
                        editActionHandler()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.white)
                            .frame(width: 60, alignment: .center)
                            .frame(maxHeight: .infinity)
                            .background(Color.itemButtonBackground)
                    }
                    .padding(.trailing, horizontalPadding)
                }
                Trailing {
                    Button {
                        deleteActionHandler()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .frame(width: 60, alignment: .center)
                            .frame(maxHeight: .infinity)
                            .background(Color.itemButtonBackground)
                    }
                    .padding(.leading, horizontalPadding)
                }
            }
    }
}
