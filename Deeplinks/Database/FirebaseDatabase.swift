//
//  FirebaseDatabase.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 14/03/2024.
//

import FirebaseCore
import FirebaseDatabase


protocol DatabaseProtocol {

    func deeplinks(for user: String, pwd: String, success: @escaping ([String]?) -> Void, failure: @escaping(DeeplinkError) -> Void)
}


class FirebaseDatabase: DatabaseProtocol {

    private var collection: [DeeplinkContent]?

    func deeplinks(for user: String, pwd: String, success: @escaping ([String]?) -> Void, failure: @escaping(DeeplinkError) -> Void) {
        fetch(success: { collection in
            if let deeplinks = collection?.filter({ $0.user == user }).first?.deeplinks {
                success(deeplinks)
            } else {
                failure(DeeplinkError(code: .invalidCredentials))
            }
        }, failure: failure)
    }

    // MARK: - Private

    private func fetch(success: @escaping ([DeeplinkContent]?) -> Void, failure: @escaping (DeeplinkError) -> Void) {
        guard collection == nil else {
            success(collection)
            return
        }

        Task {
            do {
                if let collection = try await snapshot() {
                    self.collection = collection
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
        return try snapshot.data(as: [DeeplinkContent]?.self)
    }
}
