//
//  DeeplinkError.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 14/03/2024.
//

import Foundation

enum DeeplinkErrorCode: Int, Codable, CaseIterable {

    case invalidCredentials
    case notAvailable
} 

struct DeeplinkError: Error, Equatable {

    let code: DeeplinkErrorCode
}

extension DeeplinkError {

    var displayText: String {
        switch code {
            case .notAvailable:
                return "Data not available!"
            case .invalidCredentials:
                return "Invalid user or password!"
        }
    }
}
