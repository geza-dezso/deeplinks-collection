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

    var expirationTimeout: TimeInterval = 2 * 24 * 60 * 60 // 2 days

    private let userDefaults: UserDefaults = .standard
    private let localStorageUserKey: String = "localStorageUserKey"

    func store(_ userToken: UserToken) {
        if let data = try? JSONEncoder().encode(UserTokenWithTimestamp(userToken: userToken, timestamp: Date().timeIntervalSince1970)) {
            userDefaults.set(data, forKey: localStorageUserKey)
        }
    }

    func load() -> UserToken? {
        if let data = userDefaults.data(forKey: localStorageUserKey),
           let token = try? JSONDecoder().decode(UserTokenWithTimestamp.self, from: data),
            token.timestamp + expirationTimeout > Date().timeIntervalSince1970 {
                return token.userToken
        } else {
            delete()
            return nil
        }
    }

    func delete() {
        userDefaults.removeObject(forKey: localStorageUserKey)
    }
}
