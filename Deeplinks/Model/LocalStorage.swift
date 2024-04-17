//
//  LocalStorage.swift
//  Deeplinks
//
//  Created by Geza Dezso on 17/04/2024.
//

import Foundation

protocol LocalStorageProtocol {

    @discardableResult
    func deleteObject(forKey: String) -> Bool

    func load<Object>(for key: String, castTo type: Object.Type) -> Object? where Object: Codable

    @discardableResult
    func save<Object>(value: Object, forKey key: String) -> Bool where Object: Codable
}


public class LocalStorage: NSObject, LocalStorageProtocol {

    private let userDefaults: UserDefaults = .standard

    @discardableResult
    public func deleteObject(forKey: String) -> Bool {
        userDefaults.removeObject(forKey: forKey)
        userDefaults.synchronize()
        return userDefaults.object(forKey: forKey) == nil
    }

    public func load<Object>(for key: String, castTo type: Object.Type) -> Object? where Object: Codable {
        if let data = userDefaults.data(forKey: key) {
            return try? JSONDecoder().decode(type, from: data)
        }
        return nil
    }

    @discardableResult
    public func save<Object>(value: Object, forKey key: String) -> Bool where Object: Codable {
        let data = try? JSONEncoder().encode(value)
        userDefaults.set(data, forKey: key)
        userDefaults.synchronize()
        return userDefaults.object(forKey: key) != nil
    }
}
