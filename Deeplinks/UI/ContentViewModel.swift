//
//  ContentViewModel.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 18/03/2024.
//

import Foundation
import Combine
import SwiftUI

enum ContentViewModelState: Equatable {
    case initial
    case login
    case fetching
    case ready
    case error(DeeplinkError)
}

class ContentViewModel: ObservableObject {

    @Published var deeplinkGroups: [DeeplinkGroup]?
    @Published var user: String = ""
    @Published var pwd: String = ""
    @Published var state: ContentViewModelState = .initial {
        didSet {
            if case .error(_) = state {
                shouldPresentErrorAlert = true
            } else {
                shouldPresentErrorAlert = false
            }
        }
    }
    @Published var shouldPresentErrorAlert: Bool = false

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
        login()
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
        case .invalidCredentials:
            return {
                self.onEnterCredentials()
            }
        case .notAvailable:
            return {
                self.onAuthenticated()
            }
        }
    }

    func alertButtonText(for error: DeeplinkError) -> String {
        switch error.code {
        case .invalidCredentials:
            return "Ok"
        case .notAvailable:
            return "Retry"
        }
    }

    private func login() {
        database.login(user: user, pwd: pwd)
    }

    private func setupListener() {

        databaseListener?.cancel()
        databaseListener = database.updatesPublisher(for: user)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }

                switch status {
                case .success(let deeplinkGroups):
                    self.deeplinkGroups = deeplinkGroups ?? []
                    self.userTokenHandler.store(user)
                    withAnimation {
                        self.state = .ready
                    }

                case .error(let error):
                    self.state = .error(error)

                default:
                    break
                }
            }
    }

    private func clearUserData() {
        user = ""
        pwd = ""
    }
}
