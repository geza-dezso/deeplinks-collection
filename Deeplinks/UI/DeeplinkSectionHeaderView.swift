//
//  DeeplinkSectionHeaderView.swift
//  Deeplinks
//
//  Created by Geza Dezso on 09/04/2024.
//

import SwiftUI

struct DeeplinkSectionHeaderView: View {

    let title: String

    private let padding: CGFloat = isTV ? 16 : isIPad ? 12 : 8

    var body: some View {
            Text(title)
                .font(primary)
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 0, leading: padding, bottom: 16, trailing: padding))
    }
}
