//
//  DeeplinkContent.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 14/03/2024.
//

import Foundation

struct DeeplinkContent: Codable {
    let user: String
    let pwd: String
    let deeplinks: [String]?
}
