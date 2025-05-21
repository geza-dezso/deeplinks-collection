//
//  DeeplinkFieldStyle.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2025. 05. 20..
//

import SwiftUI

struct DeeplinkFieldStyle: TextFieldStyle {

    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(primary)
            .accentColor(.lightGray)
            .foregroundColor(.lightGray)
            .padding(8)
            .background(Color.black)
            .disableAutocorrection(true)
            .keyboardType(.alphabet)
            .autocapitalization(.none)
            .cornerRadius(4.0)
    }
}
