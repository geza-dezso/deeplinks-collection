//
//  FirebaseDatabase.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 14/03/2024.
//

import FirebaseCore
import FirebaseDatabase
import Combine


enum DatabaseQueryStatus {
    case fetching
    case success([DeeplinkGroup]?)
    case error(DeeplinkError)
}


protocol DatabaseProtocol {

    func deeplinkUpdates(for user: String, pwd: String) -> AnyPublisher<DatabaseQueryStatus, Never>
}


class FirebaseDatabase: DatabaseProtocol {

    @Published public var status: DatabaseQueryStatus = .fetching

    private var user: String = ""
    private var pwd: String = ""

    private var collection: [DeeplinkContent]? {
        didSet {
            if let collection = collection {
                if let deeplinks = collection.first(where: { $0.user == user && $0.pwd == pwd })?.groups {
                    status = .success(deeplinks)
                } else {
                    status = .error(DeeplinkError(code: .invalidCredentials))
                }
            } else {
                status = .error(DeeplinkError(code: .notAvailable))
            }
        }
    }

    private var databaseListener: DatabaseHandle?

    public func deeplinkUpdates(for user: String, pwd: String) -> AnyPublisher<DatabaseQueryStatus, Never> {

        self.user = user
        self.pwd = pwd

        fetch()

        return $status
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func fetch() {
        Task {
            do {
                if let collection = try await snapshot() {
                    self.collection = collection
                    setupDatabaseListener()
                } else {
                    self.status = .error(DeeplinkError(code: .notAvailable))
                }
            } catch {
                self.status = .error(DeeplinkError(code: .notAvailable))
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
                self.status = .error(DeeplinkError(code: .notAvailable))
            }
        })
    }
}
