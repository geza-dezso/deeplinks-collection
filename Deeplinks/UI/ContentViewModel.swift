//
//  ContentViewModel.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 18/03/2024.
//

import Foundation
import Combine


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
    @Published var state: ContentViewModelState = .initial

    private var database: DatabaseProtocol
    private var bag: Set<AnyCancellable> = []
    private var databaseListener: AnyCancellable?
    private var pwd: String = ""

    init(database: DatabaseProtocol) {
        self.database = database
    }

    func onAppear() {
        state = .login
    }

    func onLogin() {
        user = "dt"
        pwd = "pwd"
        state = .fetching

        setupListener()
    }

    private func setupListener() {

        databaseListener?.cancel()
        databaseListener = database.deeplinkUpdates(for: user, pwd: pwd)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in

                switch status {
                case .success(let deeplinkGroups):
                    self?.deeplinkGroups = deeplinkGroups ?? []
                    self?.state = .ready

                case .error(let error):
                    self?.state = .error(error)

                default:
                    break
                }
            }
    }
}
