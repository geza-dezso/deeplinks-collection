//
//  UserTokenHandler.swift
//  Deeplinks
//
//  Created by Geza Dezso on 17/04/2024.
//

import Foundation

struct UserToken: Codable {
    let user: String
    let pwd: String
}

private struct UserTokenWithTimestamp: Codable {
    let userToken: UserToken
    let timestamp: TimeInterval
}

struct UserTokenHandler {

    private var localStorage: LocalStorageProtocol
    private var localStorageUserKey: String = "localStorageUserKey"
    private var expirationTimeout: TimeInterval

    init(localStorage: LocalStorageProtocol, expirationTimeout: TimeInterval? = nil) {
        self.localStorage = localStorage
        self.expirationTimeout = expirationTimeout ?? 2 * 24 * 60 * 60 // 2 days
    }

    func store(_ userToken: UserToken) {
        let tokenToSave = UserTokenWithTimestamp(userToken: userToken, timestamp: Date().timeIntervalSince1970)
        localStorage.save(value: tokenToSave, forKey: localStorageUserKey)
    }

    func load() -> UserToken? {
        if let token = localStorage.load(for: localStorageUserKey, castTo: UserTokenWithTimestamp.self),
           token.timestamp + expirationTimeout > Date().timeIntervalSince1970 {
            return token.userToken
        } else {
            delete()
            return nil
        }
    }

    func delete() {
        localStorage.deleteObject(forKey: localStorageUserKey)
    }
}
