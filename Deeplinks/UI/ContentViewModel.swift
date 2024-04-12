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
            if case .error(let error) = state {
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

    init(database: DatabaseProtocol) {
        self.database = database
    }

    func onAppear() {
        user = ""
        pwd = ""
        state = .login
    }

    func onLogin() {
        state = .fetching
        setupListener()
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

                switch status {
                case .success(let deeplinkGroups):
                    self?.deeplinkGroups = deeplinkGroups ?? []
                    withAnimation {
                        self?.state = .ready
                    }

                case .error(let error):
                    self?.state = .error(error)

                default:
                    break
                }
            }
    }
}
