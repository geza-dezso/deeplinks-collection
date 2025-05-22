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
}

struct DeeplinkGroup: Codable, Hashable {
    let id = UUID()
    var title: String
    var deeplinks: [Deeplink]?

    private enum CodingKeys: CodingKey {
        case title
        case deeplinks
    }
}

struct DeeplinkContent: Codable {
    let user: String
    let pwd: String
    let groups: [DeeplinkGroup]?
}
