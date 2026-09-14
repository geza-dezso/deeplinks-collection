//
//  SecureTextFieldStyle.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2026. 09. 14..
//

import SwiftUI

struct SecureTextFieldStyle: TextFieldStyle {

    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(primary)
            .accentColor(.lightGray)
            .foregroundColor(.lightGray)
            .padding(8)
            .frame(height: isIPad ? 44 : 36)
            .background(Color.clear)
            .disableAutocorrection(true)
            .keyboardType(.alphabet)
            .autocapitalization(.none)
            .textContentType(.oneTimeCode)
    }
}
