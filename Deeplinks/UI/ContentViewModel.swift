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
    case error(DeeplinkError)
    case edit(_ deeplink: Deeplink, for: DeeplinkGroup)
    case create(for: DeeplinkGroup)
    case section
}

@MainActor
class ContentViewModel: ObservableObject {

    @Published var deeplinkGroups: [DeeplinkGroup]?
    @Published var user: String = ""
    @Published var pwd: String = ""
    @Published var state: ContentViewModelState = .initial
    @Published var overlayState: ContentViewModelOverlayState? {
        didSet {
            if overlayState != oldValue {
                shouldPresentErrorAlert = hasError
                shouldPresentEditOverlay = hasOverlay
            }
        }
    }
    @Published var shouldPresentErrorAlert: Bool = false
    @Published var shouldPresentEditOverlay: Bool = false

    @Published var lastCreatedItemId: String?
    @Published var highlightedItemId: String?

    @Published var isUpdating = false

    private var database: DatabaseProtocol
    private var bag: Set<AnyCancellable> = []
    private var databaseListener: AnyCancellable?
    private var userTokenHandler: UserTokenHandler

    init(database: DatabaseProtocol) {
        self.database = database
        self.userTokenHandler = UserTokenHandler()
    }

    var hasError: Bool {
        guard case .error = overlayState else { return false }
        return true
    }

    var hasOverlay: Bool {
        switch overlayState {
        case .edit, .create, .section:
            return true
        default:
            return false
        }
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
        setupListener()
    }

    func onAuthenticated() {
        state = .fetching
        setupListener()
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

    func update(_ deeplink: Deeplink, in group: DeeplinkGroup) {
        guard var deeplinkGroups else { return }

        if let groupIndex = deeplinkGroups.firstIndex(where: { group == $0 }) {
            var group = deeplinkGroups[groupIndex]
            if let index = group.deeplinks?.firstIndex(where: { deeplink == $0 }) {
                group.deeplinks?[index] = deeplink
                deeplinkGroups[groupIndex] = group

                update(content: deeplinkGroups)
            } else {
                // deeplink entry not found, might have been deleted, append to group
                append(deeplink, to: group)
            }
        } else {
            // TODO: HANDLE group entry not found, might have been deleted
        }
    }

    func append(_ deeplink: Deeplink, to group: DeeplinkGroup) {
        guard var deeplinkGroups else { return }

        if let groupIndex = deeplinkGroups.firstIndex(where: { group == $0 }) {
            var group = deeplinkGroups[groupIndex]
            var deeplinks = group.deeplinks ?? []
            deeplinks.append(deeplink)
            group.deeplinks = deeplinks
            deeplinkGroups[groupIndex] = group

            update(content: deeplinkGroups) { [weak self] in
                self?.lastCreatedItemId = self?.itemIdFor(group: group, deeplink: deeplink)
            }
        } else {
            // TODO: HANDLE group entry not found, might have been deleted
        }
    }

    func append(group: DeeplinkGroup) {
        guard var deeplinkGroups else { return }

        deeplinkGroups.append(group)

        update(content: deeplinkGroups) { [weak self] in
            self?.lastCreatedItemId = self?.itemIdFor(group: group)
        }
    }

    func itemIdFor(group: DeeplinkGroup, deeplink: Deeplink? = nil) -> String {
        guard let deeplink else { return group.title }
        return "\(group.title)_\(deeplink.title)_\(deeplink.url)"
    }

    private func setupListener() {

        databaseListener?.cancel()
        databaseListener = database.updatesPublisher(user: user, pwd: pwd)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }

                switch status {
                case .success(let deeplinkGroups):
                    self.deeplinkGroups = deeplinkGroups ?? []
                    self.userTokenHandler.store(user)
                    self.state = .ready

                case .error(let error):
                    self.handleError(error)

                default:
                    break
                }
            }
    }

    private func update(content: [DeeplinkGroup], completion: (() -> Void)? = nil) {
        isUpdating = true
        Task {
            do {
                try await database.update(content: content)
                isUpdating = false
                completion?()
            } catch let error {
                isUpdating = false
                if let deeplinkError = error as? DeeplinkError {
                    handleError(deeplinkError)
                } else {
                    handleError(DeeplinkError(.updateFailed))
                }
            }
        }
    }

    private func handleError(_ error: DeeplinkError) {
        if case .invalidUserToken = error.code {
            onEnterCredentials()
            return
        }
        self.overlayState = .error(error)
    }

    private func clearUserData() {
        user = ""
        pwd = ""
    }
}
