//
//  DeeplinkError.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 14/03/2024.
//

import Foundation

enum DeeplinkErrorCode: Int, Codable, CaseIterable {

    case invalidLoginCredentials
    case invalidUserToken
    case notAvailable
} 

struct DeeplinkError: Error, Equatable {

    let code: DeeplinkErrorCode
}

extension DeeplinkError {

    var message: String {
        switch code {
            case .invalidLoginCredentials:
                return "Login failed! Please check your credentials and try again."
            case .invalidUserToken:
                return ""
            case .notAvailable:
                return "Data not available!"
        }
    }
}
