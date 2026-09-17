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
    #if os(iOS)
    case project
    #endif
}

enum ContentViewModelOverlayState: Equatable {
    case edit(_ deeplink: Deeplink, in: DeeplinkGroup)
    case create(for: DeeplinkGroup)
    case section
    case delete(_ deeplink: Deeplink, in: DeeplinkGroup)
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
        case .delete:
            return "Delete Deeplink"
        }
    }

    var message: String? {
        switch self {
        case .delete:
            return "Are you sure you want to delete this deeplink?"
        default:
            return nil
        }
    }

    var actionButtonText: String {
        switch self {
        case .delete:
            return "Delete"
        default:
            return "Save"
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
    @Published var confirmPwd: String = ""
    @Published var state: ContentViewModelState = .initial {
        didSet {
            alertState = nil
        }
    }
    @Published var overlayState: ContentViewModelOverlayState? {
        didSet {
            editingSectionTitle = ""
            editingDeeplinkTitle = ""
            editingDeeplinkUrl = ""

            if case .edit(let deeplink, _) = overlayState {
                editingDeeplinkTitle = deeplink.title
                editingDeeplinkUrl = deeplink.url
            }

            if case .delete(let deeplink, _) = overlayState {
                editingDeeplinkUrl = deeplink.url
            }
        }
    }
    @Published var alertState: ContentViewModelAlertState?

    @Published var lastCreatedItemId: String?
    @Published var highlightedItemId: String?

    @Published var isUpdating = false

    private var bag: Set<AnyCancellable> = []
    private var contentModel: DeeplinkContentModel
    private var contentModelListener: AnyCancellable?
    private var userTokenHandler: UserTokenHandler

    @Published var collapsedSections: Set<String> = []

    @Published var editingSectionTitle: String = ""
    @Published var editingDeeplinkTitle: String = ""
    @Published var editingDeeplinkUrl: String = ""

    init(contentModel: DeeplinkContentModel) {
        self.contentModel = contentModel
        self.userTokenHandler = UserTokenHandler()
    }

    // MARK: Lifecycle/states

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
        removeListeners()
        clearDeeplinkData()
        clearUserData()
        userTokenHandler.delete()
        onEnterCredentials()
    }

    #if os(iOS)
    func onNewProject() {
        clearUserData()
        state = .project
    }
    #endif

    // MARK: Actions

    func alertButtonAction(for error: DeeplinkError) -> (() -> Void) {
        switch error {
        case .invalidCredentials:
            return {
                self.onEnterCredentials()
            }
        case .dataNotAvailable:
            return {
                self.onAuthenticated()
            }
        default:
            return {}
        }
    }

    func update() {
        switch overlayState {

        case .edit(let deeplink, let group):
            let newDeeplink = Deeplink(title: editingDeeplinkTitle, url: editingDeeplinkUrl)
            contentModel.update(deeplink, with: newDeeplink, in: group)

        case .create(let group):
            let deeplink = Deeplink(title: editingDeeplinkTitle, url: editingDeeplinkUrl)
            contentModel.append(deeplink, to: group)

        case .section:
            contentModel.append(group: DeeplinkGroup(title: editingSectionTitle))

        case .delete(let deeplink, let group):
            contentModel.delete(deeplink, in: group)

        default:
            break
        }
    }

    func validate() -> DeeplinkEditError? {
        switch overlayState {

        case .edit(let deeplink, let group):
            return contentModel.validate(
                Deeplink(title: editingDeeplinkTitle, url: editingDeeplinkUrl), oldValue: deeplink, in: group
            )

        case .create(let group):
            return contentModel.validate(
                Deeplink(title: editingDeeplinkTitle, url: editingDeeplinkUrl), in: group
            )

        case .section:
            return contentModel.validate(editingSectionTitle)

        default:
            return nil
        }
    }

    func handle(_ error: DeeplinkError) {
        guard error != .invalidUserToken else {
            onEnterCredentials()
            return
        }
        if overlayState != nil {
            withAnimation(.easeInOut(duration: 0.3)) {
                overlayState = nil
            } completion: {
                DispatchQueue.main.async {
                    self.alertState = .error(error)
                }
            }
        } else {
            alertState = .error(error)
        }
    }

    var hasChanged: Bool {
        switch overlayState {
        case .edit(let deeplink, _):
            return deeplink.title != editingDeeplinkTitle || deeplink.url != editingDeeplinkUrl
        default:
            return true
        }
    }

    func itemIdFor(groupTitle: String, deeplink: Deeplink? = nil) -> String {
        guard let deeplink else { return groupTitle }
        return "\(groupTitle)_\(deeplink.title)_\(deeplink.url)"
    }

    // MARK: Section toggle

    func toggle(_ group: DeeplinkGroup) {
        if collapsedSections.contains(group.title) {
            expand(group)
        } else {
            collapsedSections.insert(group.title)
        }
    }

    func expand(_ group: DeeplinkGroup) {
        collapsedSections.remove(group.title)
    }

    func isCollapsed(_ group: DeeplinkGroup) -> Bool {
        collapsedSections.contains(group.title)
    }

    // MARK: Private

    private func setupListeners() {

        contentModelListener?.cancel()
        contentModelListener = contentModel.updatesPublisher(user: user, pwd: pwd)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] modelState in
                guard let self else { return }

                switch modelState {

                case .fetching:
                    state = .fetching

                case .ready(let result):
                    deeplinkGroups = result ?? []
                    userTokenHandler.store(user)
                    state = .ready

                case .error(let error):
                    handle(error)
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

        contentModel.updateError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self, let error else { return }
                handle(error)
            }.store(in: &bag)
    }

    private func removeListeners() {
        contentModelListener?.cancel()
        bag.removeAll()
    }

    private func clearUserData() {
        user = ""
        pwd = ""
        confirmPwd = ""
    }

    private func clearDeeplinkData() {
        deeplinkGroups = nil
    }
}
