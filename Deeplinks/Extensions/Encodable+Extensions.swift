//
//  Encodable+Extensions.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2025. 05. 26..
//

import Foundation

extension Encodable {
    var asDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }

        return
            (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
                .flatMap { $0 as? [String: Any] }
    }
}
