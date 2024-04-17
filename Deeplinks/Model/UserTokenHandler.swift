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

struct UserTokenHandler {

    private var localStorage: LocalStorageProtocol
    private var localStorageUserKey = "localStorageUserKey"

    init(localStorage: LocalStorageProtocol) {
        self.localStorage = localStorage
    }

    func store(_ userToken: UserToken) {
        localStorage.save(value: userToken, forKey: localStorageUserKey)
    }

    func load() -> UserToken? {
        return localStorage.load(for: localStorageUserKey, castTo: UserToken.self)
    }

    func delete() {
        localStorage.deleteObject(forKey: localStorageUserKey)
    }
}
