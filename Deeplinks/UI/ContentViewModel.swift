//
//  ContentViewModel.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 18/03/2024.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {

    @Published var deeplinks: [String]?

    @Published var isLoading: Bool = true
    @Published var error: DeeplinkError?

    private var database: DatabaseProtocol
    private var bag: Set<AnyCancellable> = []
    private var databaseListener: AnyCancellable?

    private var user: String
    private var pwd: String

    init(database: DatabaseProtocol) {
        self.database = database
        self.user = "user1"
        self.pwd = "pwd1"
    }

    func onAppear() {
        fetchDeeplinks(for: self.user, pwd: self.pwd) { [weak self] success in
            guard let self = self else { return }

            if success {
                self.listenToDatabaseChanges(for: self.user)
            }
        }
    }

    private func fetchDeeplinks(for user: String, pwd: String, completion: @escaping (Bool) ->Void) {
        guard !user.isEmpty, !pwd.isEmpty else {
            self.deeplinks = nil
            self.error = DeeplinkError(code: .invalidCredentials)
            completion(false)
            return
        }

        isLoading = true
        database.deeplinks(for: user, pwd: pwd) { [weak self] deeplinks in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.deeplinks = deeplinks
                self.error = nil
                self.isLoading = false
                completion(true)
            }

        } failure: { [weak self] error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.deeplinks = nil
                self.error = error
                self.isLoading = false
                completion(false)
            }
        }
    }

    private func listenToDatabaseChanges(for user: String) {
        databaseListener?.cancel()
        databaseListener = database.deeplinkUpdates(for: user)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] deeplinks in
                self?.deeplinks = deeplinks ?? []
            }
    }
}
