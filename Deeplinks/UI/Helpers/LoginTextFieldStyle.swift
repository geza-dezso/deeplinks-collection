//
//  LoginTextFieldStyle.swift
//  Deeplinks
//
//  Created by Geza Dezso on 11/04/2024.
//

import SwiftUI

struct LoginTextFieldStyle: TextFieldStyle {

    #if os(iOS)

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(primary)
            .accentColor(.lightGray)
            .foregroundColor(.lightGray)
            .padding(8)
            .background(Color.itemBackground)
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
            .accentColor(.lightGray)
            .foregroundColor(.lightGray)
            .background(Color.itemBackground)
            .disableAutocorrection(true)
            .keyboardType(.alphabet)
            .autocapitalization(.none)
    }

    #endif
}
