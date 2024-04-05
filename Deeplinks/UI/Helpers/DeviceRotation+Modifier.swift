//
//  DeviceRotation+Modifier.swift
//  Deeplinks
//
//  Created by Geza Dezso on 04/04/2024.
//

import SwiftUI

struct DeviceRotationViewModifier: ViewModifier {
    let action: (Bool) -> Void

    #if os(iOS)
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                DispatchQueue.main.async {
                    action(UIDevice.current.orientation.isPortrait)
                }
            }
    }
    #else
    func body(content: Content) -> some View {
        content
    }
    #endif
}

extension View {
    func onDeviceRotation(perform action: @escaping (Bool) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
