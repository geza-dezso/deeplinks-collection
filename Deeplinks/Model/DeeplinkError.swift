//
//  DeeplinkError.swift
//  Deeplinks
//
//  Created by Geza Dezso on 14/03/2024.
//

import Foundation

enum DeeplinkErrorCode: Int, Codable, CaseIterable {

    case invalidLoginCredentials
    case invalidUserToken
    case dataNotAvailable
    case updateFailed
    case comingSoon
}

struct DeeplinkError: Error, Equatable {

    var code: DeeplinkErrorCode

    init(_ code: DeeplinkErrorCode) {
        self.code = code
    }
}

extension DeeplinkError {

    var message: String? {
        switch code {
        case .invalidLoginCredentials:
            return "Login failed! Please check your credentials and try again."
        case .invalidUserToken:
            return nil
        case .dataNotAvailable:
            return "Data not available!"
        case .updateFailed:
            return "Updating data failed. Please try again later."
        case .comingSoon:
            return "Coming soon!"
        }
    }

    var buttonText: String {
        switch code {
        case .invalidLoginCredentials:
            return "Ok"
        case .invalidUserToken:
            return ""
        case .dataNotAvailable:
            return "Retry"
        case .updateFailed:
            return "Ok"
        case .comingSoon:
            return "Ok"
        }
    }
}
