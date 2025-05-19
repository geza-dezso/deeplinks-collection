//
//  FirebaseDatabase.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 14/03/2024.
//

import FirebaseCore
import FirebaseDatabase
import Combine


enum DatabaseQueryStatus: Equatable {
    case none
    case fetching
    case success([DeeplinkGroup]?)
    case error(DeeplinkError)
}


enum PwdCheckOptions {
    case none
    case enabled(pwd: String)
}

protocol DatabaseProtocol {

    func updatesPublisher(user: String, pwd: String) -> AnyPublisher<DatabaseQueryStatus, Never>
}


class FirebaseDatabase: DatabaseProtocol {

    @Published public var status: DatabaseQueryStatus = .none

    private var user: String = ""
    private var pwdCheckOptions: PwdCheckOptions = .none

    private var collection: [DeeplinkContent]? {
        didSet {
            updateStatus()
        }
    }

    private var databaseListener: DatabaseHandle?

    public func updatesPublisher(user: String, pwd: String = "") -> AnyPublisher<DatabaseQueryStatus, Never> {

        self.user = user
        if !pwd.isEmpty {
            pwdCheckOptions = .enabled(pwd: pwd)
        } else {
            pwdCheckOptions = .none
        }

        fetchIfNeeded()

        return $status
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func fetchIfNeeded() {
        guard status != .fetching else { return }
        guard collection == nil else {
            updateStatus()
            return
        }

        status = .fetching

        Task {
            do {
                self.collection = try await snapshot()
                setupDatabaseListener()
            } catch {
                updateStatus()
            }
        }
    }

    private func snapshot() async throws -> [DeeplinkContent]? {
        let reference = Database.database().reference()
        let snapshot = try await reference.child("content").getData()
        return try snapshot.data(as: [DeeplinkContent].self)
    }

    private func setupDatabaseListener() {
        guard databaseListener == nil else { return }

        let reference = Database.database().reference()
        databaseListener = reference.observe(.childChanged, with: { snapshot in
            do {
                self.collection = try snapshot.data(as: [DeeplinkContent].self)
            } catch {
                self.updateStatus()
            }
        })
    }

    private func updateStatus() {
        if let collection = collection {
            if let deeplinks = collection.first(where: { $0.user == user }) {
                if case .enabled(let pwd) = pwdCheckOptions {
                    if deeplinks.pwd == pwd {
                        pwdCheckOptions = .none
                        status = .success(deeplinks.groups)
                    } else {
                        status = .error(DeeplinkError(.invalidLoginCredentials))
                    }
                } else {
                    status = .success(deeplinks.groups)
                }
            } else {
                if case .enabled = pwdCheckOptions {
                    status = .error(DeeplinkError(.invalidLoginCredentials))
                } else {
                    status = .error(DeeplinkError(.invalidUserToken))
                }
            }
        } else {
            status = .error(DeeplinkError(.dataNotAvailable))
        }
    }
}
