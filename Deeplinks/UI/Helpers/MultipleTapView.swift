//
//  MultipleTapView.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2026. 08. 30..
//

import SwiftUI

struct MultipleTapView: View {

    var numberOfTaps: Int
    var action: () -> Void

    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture(count: numberOfTaps) {
                action()
            }
    }
}
