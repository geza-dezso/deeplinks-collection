//
//  DeeplinkError.swift
//  Deeplinks
//
//  Created by Geza Dezso on 14/03/2024.
//

import Foundation

enum DeeplinkError: Equatable {
    case dataNotAvailable
    case invalidCredentials
    case invalidUserToken
    case openUrlInvalid
    case openUrlFailed
    case updateFailed
    case updateSectionNotFound
}

extension DeeplinkError {

    var message: String {
        switch self {
        case .dataNotAvailable:
            return "Data not available!"
        case .invalidCredentials:
            return "Login failed! Please check your credentials and try again."
        case .invalidUserToken:
            return ""
        case .openUrlInvalid:
            return "This doesn't seem like a valid deeplink."
        case .openUrlFailed:
            return "Failed to open deeplink!"
        case .updateFailed:
            return "Updating data failed! Please try again later."
        case .updateSectionNotFound:
            return "Updating data failed! The section trying to update doesn't exist, might be deleted by another user."
        }
    }

    var alertButtonText: String {
        switch self {
        case .invalidCredentials, .openUrlFailed, .openUrlInvalid, .updateFailed, .updateSectionNotFound:
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
