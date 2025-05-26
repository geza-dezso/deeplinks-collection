//
//  SwipeActions.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2025. 05. 20..
//

import SwiftUI
import SwipeActions

public extension View {
    func itemSwipeActions(
        state: Binding<SwipeState> = .constant(.untouched),
        editAction: @escaping () -> Void,
        deleteAction: @escaping () -> Void
    ) -> some View {
        self.modifier(
            ItemSwipeActionsModifier(
                state: state,
                editAction: editAction,
                deleteAction: deleteAction
            )
        )
    }
}

struct ItemSwipeActionsModifier: ViewModifier {
    var state: Binding<SwipeState> = .constant(.untouched)
    let editAction: () -> Void
    let deleteAction: () -> Void

    func body(content: Content) -> some View {
        content
            .addSwipeAction(menu: .slided, state: state) {
                Leading {
                    Button {
                        editAction()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.white)
                            .frame(width: 60, alignment: .center)
                            .frame(maxHeight: .infinity)
                            .background(Color.buttonBackground)
                    }
                }
                Trailing {
                    Button {
                        deleteAction()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .frame(width: 60, alignment: .center)
                            .frame(maxHeight: .infinity)
                            .background(Color.buttonBackground)
                    }
                }
            }
    }
}
