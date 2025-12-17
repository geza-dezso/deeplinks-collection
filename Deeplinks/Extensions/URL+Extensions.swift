//
//  URL+Extensions.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2025. 12. 16..
//

import Foundation

extension URL {
    init?(_ string: String) {
        guard let url = URL(string: string) else { return nil }

        // can be of format "https://whatever..." or "scheme://whatever..."
        guard let range = string.range(of: "://") else { return nil }

        // must be some text before "://"
        let pre = string[..<range.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        if pre.isEmpty { return nil }

        // must be some text after "://"
        let post = string[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
        if post.isEmpty { return nil }

        self = url
    }
}
