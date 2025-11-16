//
//  ContentViewModel+Validity.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2025. 11. 09..
//

import Foundation

extension ContentViewModel {

    func checkValidity(for sectionTitle: String) -> Bool {
        return checkDuplicate(for: sectionTitle)
    }

    private func checkDuplicate(for sectionTitle: String) -> Bool {
        guard let deeplinkGroups else {
            return true
        }
        guard deeplinkGroups.first(where: { $0.title == sectionTitle }) == nil else {
            return false
        }
        return true
    }
}
