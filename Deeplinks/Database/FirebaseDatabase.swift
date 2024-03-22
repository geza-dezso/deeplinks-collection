//
//  FirebaseDatabase.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 14/03/2024.
//

import FirebaseCore
import FirebaseDatabase
import Combine


protocol DatabaseProtocol {

    func deeplinks(for user: String, pwd: String, success: @escaping ([String]?) -> Void, failure: @escaping(DeeplinkError) -> Void)
    func deeplinkUpdates(for user: String) -> AnyPublisher<[String]?, Never>
}


class FirebaseDatabase: DatabaseProtocol {

    @Published public var collection: [DeeplinkContent] = []

    private var databaseListener: DatabaseHandle?

    func deeplinks(for user: String, pwd: String, success: @escaping ([String]?) -> Void, failure: @escaping(DeeplinkError) -> Void) {
        fetch(success: { collection in
            if let deeplinks = collection?.filter({ $0.user == user }).first?.deeplinks {
                success(deeplinks)
            } else {
                failure(DeeplinkError(code: .invalidCredentials))
            }
        }, failure: failure)
    }

    public func deeplinkUpdates(for user: String) -> AnyPublisher<[String]?, Never> {
        $collection
            .map { $0.first(where: { $0.user == user })?.deeplinks }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func fetch(success: @escaping ([DeeplinkContent]?) -> Void, failure: @escaping (DeeplinkError) -> Void) {
        Task {
            do {
                if let collection = try await snapshot() {
                    self.collection = collection
                    setupDatabaseListener()
                    success(collection)
                } else {
                    failure(DeeplinkError(code: .notAvailable))
                }
            } catch {
                failure(DeeplinkError(code: .notAvailable))
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
            } catch {}
        })
    }
}
