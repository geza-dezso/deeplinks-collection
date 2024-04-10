//
//  DeeplinkContent.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 14/03/2024.
//

import Foundation

struct Deeplink: Codable, Hashable {
    let title: String
    let url: String
}

struct DeeplinkGroup: Codable, Hashable {
    let title: String
    let deeplinks: [Deeplink]?
}

struct DeeplinkContent: Codable {
    let user: String
    let pwd: String
    let groups: [DeeplinkGroup]?
}
