//
//  View+Extensions.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2026. 09. 11..
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
