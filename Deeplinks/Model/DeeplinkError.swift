//
//  DeeplinkError.swift
//  Deeplinks
//
//  Created by Geza Dezso on 14/03/2024.
//

import Foundation

enum DeeplinkError: Equatable {
    case invalidLoginCredentials
    case invalidUserToken
    case dataNotAvailable
    case updateFailed
    case comingSoon
    case duplicate(isSection: Bool)
    case invalidUrl
}

extension DeeplinkError {

    var message: String {
        switch self {
        case .invalidLoginCredentials:
            return "Login failed! Please check your credentials and try again."
        case .invalidUserToken:
            return ""
        case .dataNotAvailable:
            return "Data not available!"
        case .updateFailed:
            return "Updating data failed. Please try again later."
        case .comingSoon:
            return "Coming soon!"
        case .duplicate(isSection: true):
            return "A section with this name already exists."
        case .duplicate(isSection: false):
            return "A deeplink with this title and URL already exists."
        case .invalidUrl:
            return "This doesn't seem like a valid deeplink."
        }
    }

    var alertButtonText: String {
        switch self {
        case .invalidLoginCredentials, .updateFailed, .comingSoon:
            return "Ok"
        case .dataNotAvailable:
            return "Retry"
        default:
            return ""
        }
    }

    var shouldShowAlert: Bool {
        return alertErrors.contains(self)
    }

    private var alertErrors: [DeeplinkError] {
        return [.invalidLoginCredentials, .dataNotAvailable, .updateFailed, .comingSoon]
    }
}
