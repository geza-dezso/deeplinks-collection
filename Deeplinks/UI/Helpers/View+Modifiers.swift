//
//  View+Modifiers.swift
//  Deeplinks
//
//  Created by Geza Dezso on 04/04/2024.
//

import SwiftUI

struct DeviceRotationViewModifier: ViewModifier {
    let action: (Bool) -> Void

    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                DispatchQueue.main.async {
                    action(UIDevice.current.orientation.isPortrait)
                }
            }
        #else
        content
        #endif
    }
}


struct ScrollContentBackgroundViewModifier: ViewModifier {
    var visibility: Visibility

    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 16, *) {
            content
                .scrollContentBackground(visibility)
        } else {
            content
        }
        #else
        content
        #endif
    }
}


extension View {
    func onDeviceRotation(perform action: @escaping (Bool) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }

    @ViewBuilder
    func contentBackground(_ visibility: Visibility) -> some View {
        self.modifier(ScrollContentBackgroundViewModifier(visibility: visibility))
    }
}
