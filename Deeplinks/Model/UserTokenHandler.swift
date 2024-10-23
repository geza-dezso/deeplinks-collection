//
//  UserTokenHandler.swift
//  Deeplinks
//
//  Created by Geza Dezso on 17/04/2024.
//

import Foundation

private struct UserToken: Codable {
    let user: String
    let timestamp: TimeInterval
}

struct UserTokenHandler {

    private let userDefaults: UserDefaults = .standard
    private let localStorageUserKey: String = "localStorageUserKey"

    func store(_ user: String) {
        if let data = try? JSONEncoder().encode(UserToken(user: user, timestamp: Date().timeIntervalSince1970)) {
            userDefaults.set(data, forKey: localStorageUserKey)
        }
    }

    func load() -> String? {
        if let data = userDefaults.data(forKey: localStorageUserKey),
           let token = try? JSONDecoder().decode(UserToken.self, from: data) {
                return token.user
        } else {
            delete()
            return nil
        }
    }

    func delete() {
        userDefaults.removeObject(forKey: localStorageUserKey)
    }
}
