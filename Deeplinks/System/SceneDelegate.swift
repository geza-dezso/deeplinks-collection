//
//  SceneDelegate.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 18/03/2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        let viewController = HostingViewController(rootView: ContentView(viewModel: ContentViewModel()))
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}

