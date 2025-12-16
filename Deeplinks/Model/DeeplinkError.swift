//
//  DeeplinkError.swift
//  Deeplinks
//
//  Created by Geza Dezso on 14/03/2024.
//

import Foundation

enum DeeplinkError: Equatable {
    case comingSoon
    case dataNotAvailable
    case invalidLoginCredentials
    case invalidUserToken
    case openUrlInvalid
    case openUrlFailed
    case updateFailed
}

extension DeeplinkError {

    var message: String {
        switch self {
        case .comingSoon:
            return "Coming soon!"
        case .dataNotAvailable:
            return "Data not available!"
        case .invalidLoginCredentials:
            return "Login failed! Please check your credentials and try again."
        case .invalidUserToken:
            return ""
        case .openUrlInvalid:
            return "This doesn't seem like a valid deeplink."
        case .openUrlFailed:
            return "Failed to open deeplink!"
        case .updateFailed:
            return "Updating data failed. Please try again later."
        }
    }

    var alertButtonText: String {
        switch self {
        case  .comingSoon, .invalidLoginCredentials, .openUrlFailed, .openUrlInvalid, .updateFailed:
            return "Ok"
        case .dataNotAvailable:
            return "Retry"
        case .invalidUserToken:
            return ""
        }
    }
}

enum DeeplinkEditError: Equatable {
    case duplicate(isSection: Bool)
    case invalidUrl
}

extension DeeplinkEditError {
    var message: String {
        switch self {
        case .duplicate(isSection: true):
            return "A section with this name already exists."
        case .duplicate(isSection: false):
            return "A deeplink with this title and URL already exists."
        case .invalidUrl:
            return "This doesn't seem like a valid deeplink."
        }
    }
}
