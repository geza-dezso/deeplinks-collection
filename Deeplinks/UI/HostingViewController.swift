//
//  HostingViewController.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 18/03/2024.
//

import SwiftUI

class HostingViewController<Content>: UIHostingController<Content> where Content: View {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
    }

    #if os(iOS)
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return isIPad ? .all : .portrait
    }
    #endif
}
