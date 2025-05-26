//
//  DeeplinkContent.swift
//  Deeplinks
//
//  Created by Geza Dezso on 14/03/2024.
//

import Foundation

struct Deeplink: Codable, Hashable {
    let id = UUID()
    var title: String
    var url: String

    private enum CodingKeys: CodingKey {
        case title
        case url
    }

    var isEmpty: Bool {
        title.isEmpty || url.isEmpty
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

struct DeeplinkGroup: Codable, Hashable {
    let id = UUID()
    var title: String
    var deeplinks: [Deeplink]?

    private enum CodingKeys: CodingKey {
        case title
        case deeplinks
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

struct DeeplinkContent: Codable {
    let user: String
    let pwd: String
    var groups: [DeeplinkGroup]?

    private enum CodingKeys: CodingKey {
        case user
        case pwd
        case groups
    }
}
