//
//  ContentViewModel.swift
//  Deeplinks
//
//  Created by Geza Dezso on 18/03/2024.
//

import Combine
import SwiftUI

enum ContentViewModelState: Equatable {
    case initial
    case login
    case fetching
    case ready
}

enum ContentViewModelOverlayState: Equatable {
    case edit(_ deeplink: Deeplink, for: DeeplinkGroup)
    case create(for: DeeplinkGroup)
    case section
}

extension ContentViewModelOverlayState {
    var title: String {
        switch self {
        case .edit:
            return "Edit Deeplink"
        case .create:
            return "Create Deeplink"
        case .section:
            return "Create Section"
        }
    }
}

enum ContentViewModelAlertState: Equatable {
    case error(DeeplinkError)
}

@MainActor
class ContentViewModel: ObservableObject {

    @Published var deeplinkGroups: [DeeplinkGroup]?
    @Published var user: String = ""
    @Published var pwd: String = ""
    @Published var state: ContentViewModelState = .initial
    @Published var overlayState: ContentViewModelOverlayState?
    @Published var alertState: ContentViewModelAlertState?

    @Published var lastCreatedItemId: String?
    @Published var highlightedItemId: String?

    @Published var isUpdating = false

    private var bag: Set<AnyCancellable> = []
    private var contentModel: DeeplinkContentModel
    private var contentModelListener: AnyCancellable?
    private var userTokenHandler: UserTokenHandler

    init(contentModel: DeeplinkContentModel) {
        self.contentModel = contentModel
        self.userTokenHandler = UserTokenHandler()
    }

    func onAppear() {
        if let user = userTokenHandler.load() {
            self.user = user
            onAuthenticated()
        } else {
            onEnterCredentials()
        }
    }

    func onEnterCredentials() {
        clearUserData()
        state = .login
    }

    func onLogin() {
        state = .fetching
        setupListeners()
    }

    func onAuthenticated() {
        state = .fetching
        setupListeners()
    }

    func onLogout() {
        clearUserData()
        userTokenHandler.delete()
        onEnterCredentials()
    }

    func alertButtonAction(for error: DeeplinkError) -> (() -> Void) {
        switch error.code {
        case .invalidLoginCredentials:
            return {
                self.onEnterCredentials()
            }
        case .invalidUserToken:
            return {}
        case .dataNotAvailable:
            return {
                self.onAuthenticated()
            }
        case .updateFailed:
            return {}
        case .comingSoon:
            return {}
        }
    }

    func update(_ deeplink: Deeplink, with newDeeplink: Deeplink, in group: DeeplinkGroup) {
        contentModel.update(deeplink, with: newDeeplink, in: group)
    }

    func append(_ deeplink: Deeplink, to group: DeeplinkGroup) {
        contentModel.append(deeplink, to: group)
    }

    func append(group: DeeplinkGroup) {
        contentModel.append(group: group)
    }

    func checkValidity(for groupTitle: String) -> Bool {
        return contentModel.checkValidity(for: groupTitle)
    }

    func checkValidity(for newDeeplink: Deeplink, oldValue: Deeplink? = nil, in group: DeeplinkGroup) -> Bool {
        return contentModel.checkValidity(for: newDeeplink, oldValue: oldValue, in: group)
    }

    func itemIdFor(groupTitle: String, deeplink: Deeplink? = nil) -> String {
        guard let deeplink else { return groupTitle }
        return "\(groupTitle)_\(deeplink.title)_\(deeplink.url)"
    }

    private func setupListeners() {

        contentModelListener?.cancel()
        contentModelListener = contentModel.updatesPublisher(user: user, pwd: pwd)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] modelState in
                guard let self else { return }

                switch modelState {
                case .ready(let result):
                    deeplinkGroups = result ?? []
                    userTokenHandler.store(user)
                    state = .ready

                case .error(let error):
                    handleError(error)

                default:
                    break
                }
            }

        contentModel.lastCreatedItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                guard let self, let item else { return }

                switch item {
                case .group(let title):
                    lastCreatedItemId = itemIdFor(groupTitle: title)
                case .deeplink(let groupTitle, let deeplink):
                    lastCreatedItemId = itemIdFor(groupTitle: groupTitle, deeplink: deeplink)
                }
            }.store(in: &bag)
    }

    private func handleError(_ error: DeeplinkError) {
        if case .invalidUserToken = error.code {
            onEnterCredentials()
            return
        }
        self.alertState = .error(error)
    }

    private func clearUserData() {
        user = ""
        pwd = ""
    }
}
