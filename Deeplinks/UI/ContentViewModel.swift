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

    init(database: DatabaseProtocol, localStorage: LocalStorageProtocol) {
        self.database = database
        self.userTokenHandler = UserTokenHandler(localStorage: localStorage)
    }

    func onAppear() {
        if let userToken = userTokenHandler.load() {
            user = userToken.user
            pwd = userToken.pwd
            onLogin()
        } else {
            user = ""
            pwd = ""
            state = .login
        }
    }

    func onLogin() {
        state = .fetching
        setupListener()
    }

    func onLogout() {
        user = ""
        pwd = ""
        userTokenHandler.delete()
        onAppear()
    }

    func alertButtonAction(for error: DeeplinkError) -> (() -> Void) {
        switch error.code {
        case .invalidCredentials:
            return {
                self.onAppear()
            }
        case .notAvailable:
            return {
                self.onLogin()
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

    private func setupListener() {

        databaseListener?.cancel()
        databaseListener = database.deeplinkUpdates(for: user, pwd: pwd)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }

                switch status {
                case .success(let deeplinkGroups):
                    self.deeplinkGroups = deeplinkGroups ?? []
                    self.userTokenHandler.store(UserToken(user: user, pwd: pwd))
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
}
