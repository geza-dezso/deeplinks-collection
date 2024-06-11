//
//  TopBottomFadingGradientView.swift
//  Deeplinks
//
//  Created by Geza Dezso on 05/06/2024.
//

import SwiftUI

struct TopBottomGradientView: View {
    let gradientHeight: CGFloat
    
    var body: some View {

        VStack(spacing: 0) {
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0), .black]),
                startPoint: UnitPoint(x: 0, y: 0),
                endPoint: UnitPoint(x: 0, y: 1)
            )
            .frame(height: isTV ? 48 : isIPad ? 32 : 24)

            Color.black
                .frame(maxHeight: .infinity)

            LinearGradient(
                gradient: Gradient(colors: [.black, .black.opacity(0)]),
                startPoint: UnitPoint(x: 0, y: 0),
                endPoint: UnitPoint(x: 0, y: 1)
            )
            .frame(height: isTV ? 48 : isIPad ? 32 : 24)
        }
    }
}
