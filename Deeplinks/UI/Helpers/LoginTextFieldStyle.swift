//
//  LoginTextFieldStyle.swift
//  Deeplinks
//
//  Created by Geza Dezso on 11/04/2024.
//

import SwiftUI

struct LoginTextFieldStyle: TextFieldStyle {

    private var textColor = Color(red: 0.66, green: 0.66, blue: 0.66)

    #if os(iOS)

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(primary)
            .accentColor(textColor)
            .foregroundColor(textColor)
            .padding(8)
            .background(Color.white.opacity(0.1))
            .disableAutocorrection(true)
            .keyboardType(.alphabet)
            .autocapitalization(.none)
            .cornerRadius(4.0)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.gray, lineWidth: 1)
            )
    }

    #else

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(primary)
            .accentColor(textColor)
            .foregroundColor(textColor)
            .background(Color.white.opacity(0.1))
            .disableAutocorrection(true)
            .keyboardType(.alphabet)
            .autocapitalization(.none)
    }

    #endif
}
