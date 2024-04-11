//
//  LoginTextFieldStyle.swift
//  Deeplinks
//
//  Created by Geza Dezso on 11/04/2024.
//

import SwiftUI

struct LoginTextFieldStyle: TextFieldStyle {

    private var textColor = Color(red: 0.66, green: 0.66, blue: 0.66)

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(primary)
            .accentColor(textColor)
            .foregroundColor(textColor)
            .padding(8)
            .border(.secondary)
            .background(Color.white.opacity(0.1))
            .disableAutocorrection(true)
            .keyboardType(.alphabet)
    }
}
