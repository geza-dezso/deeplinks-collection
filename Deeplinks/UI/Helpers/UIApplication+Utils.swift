//
//  UIApplication+Utils.swift
//  Deeplinks
//
//  Created by Geza Dezso on 04/04/2024.
//

import SwiftUI

extension UIApplication {

#if os(iOS)
    var currentScene: UIWindowScene? {
        for scene in self.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows where window.isKeyWindow {
                return windowScene
            }
        }
        return nil
    }

    var keyWindow: UIWindow? { currentScene?.keyWindow }

    var isPortrait: Bool {
        keyWindow?.windowScene?.interfaceOrientation.isPortrait ?? false
    }
#else
    var isPortrait: Bool { false }
#endif

}
