//
//  MultipleTapView.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2026. 08. 30..
//

import SwiftUI

struct MultipleTapView: View {

    let numberOfTaps: Int
    let action: () -> Void

    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture(count: numberOfTaps) {
                action()
            }
    }
}
