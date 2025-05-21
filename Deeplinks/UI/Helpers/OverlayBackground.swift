//
//  OverlayBackground.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2025. 05. 20..
//

import SwiftUI

struct OverlayBackgroundModifier: ViewModifier {
    let backgroundColor: Color

    func body(content: Content) -> some View {
        if #available(iOS 16.4, tvOS 16.4, *) {
            content
                .presentationBackground(backgroundColor)
        } else {
            content
                .background(TransparentBackgroundView(backgroundColor))
        }
    }

    private struct TransparentBackgroundView: UIViewRepresentable {
        let backgroundColor: UIColor

        init(_ backgroundColor: Color) {
            self.backgroundColor = UIColor(backgroundColor)
        }

        func makeUIView(context: Context) -> UIView {
            let backgroundView = BackgroundView()
            backgroundView.background = backgroundColor
            return backgroundView
        }

        func updateUIView(_ uiView: UIView, context: Context) {
        }
    }

    private class BackgroundView: UIView {
        var background: UIColor?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = self.background
        }
    }
}

extension View {
    func overlayBackground(_ backgroundColor: Color = .black.opacity(0.5)) -> some View {
        self.modifier(OverlayBackgroundModifier(backgroundColor: backgroundColor))
    }
}
