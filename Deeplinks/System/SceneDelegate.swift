//
//  SceneDelegate.swift
//  Deeplinks
//
//  Created by Geza Dezso on 18/03/2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        let contentModel = DeeplinkContentModel(database: FirebaseDatabase())
        let contentViewModel = ContentViewModel(contentModel: contentModel)
        let contentView = ContentView(viewModel: contentViewModel)
        let viewController = HostingViewController(rootView: contentView)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}
