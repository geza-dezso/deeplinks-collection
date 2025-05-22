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
    case edit
    case create(for: UUID)
    case group
}

class ContentViewModel: ObservableObject {

    @Published var deeplinkGroups: [DeeplinkGroup]?
    @Published var user: String = ""
    @Published var pwd: String = ""
    @Published var state: ContentViewModelState = .initial
    @Published var overlayState: ContentViewModelOverlayState? {
        didSet {
            if overlayState != oldValue {
                shouldPresentErrorAlert = false
                shouldPresentEditOverlay = false
                switch overlayState {
                case .error:
                    shouldPresentErrorAlert = true
                case .edit, .create:
                    shouldPresentEditOverlay = true
                default:
                    break
                }
            }
        }
    }
    @Published var shouldPresentErrorAlert: Bool = false
    @Published var shouldPresentEditOverlay: Bool = false

    @Published var editingItem = Deeplink(title: "", url: "")

    private var database: DatabaseProtocol
    private var bag: Set<AnyCancellable> = []
    private var databaseListener: AnyCancellable?
    private var userTokenHandler: UserTokenHandler

    init(database: DatabaseProtocol) {
        self.database = database
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
        case .comingSoon:
            return {}
        }
    }

    func update() {
        switch overlayState {
        case .edit:
            update(with: editingItem)
        case .create(let groupId):
            add(editingItem, to: groupId)
        case .group:
            break
        default:
            break
        }
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

    private func update(with deeplink: Deeplink) {
        guard var deeplinkGroups else { return }

        for (groupIndex, var group) in deeplinkGroups.enumerated() {
            if let index = group.deeplinks?.firstIndex(where: { deeplink.id == $0.id }) {
                group.deeplinks?[index] = deeplink
                deeplinkGroups[groupIndex] = group
                self.deeplinkGroups = deeplinkGroups
            }
        }
    }

    private func add(_ deeplink: Deeplink, to groupId: UUID) {
        guard var deeplinkGroups else { return }

        if let index = deeplinkGroups.firstIndex(where: { groupId == $0.id }) {
            var group = deeplinkGroups[index]
            group.deeplinks?.append(deeplink)
            deeplinkGroups[index] = group
            self.deeplinkGroups = deeplinkGroups
        }
    }
}
