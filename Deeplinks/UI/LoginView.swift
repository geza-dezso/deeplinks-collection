//
//  LoginView.swift
//  Deeplinks
//
//  Created by Geza Dezso on 11/04/2024.
//

import SwiftUI

private enum Field: Int, Hashable {
    case username, password
}

struct LoginView: View {
    @ObservedObject var viewModel: ContentViewModel

    @FocusState private var focusedField: Field?

    private let placeholderTextColor = Color(red: 0.33, green: 0.33, blue: 0.33)

    var body: some View {
        VStack {
            usernameTextField

            passwordTextField

            Spacer()
                .frame(height: 24)

            Button(action: {
                focusedField = nil
                viewModel.onLogin()
            }, label: {
                Text("Login")
                    .font(primary)
            })
        }
        .frame(width: 280)
    }

    private var usernameTextField: some View {
        TextField(
            "",
            text: $viewModel.user,
            prompt: Text("Username").foregroundColor(placeholderTextColor)
        )
        .textFieldStyle(LoginTextFieldStyle())
        .focused($focusedField, equals: .username)
        .onSubmit {
            focusedField = .password
        }
    }

    private var passwordTextField: some View {
        TextField(
            "",
            text: $viewModel.pwd,
            prompt: Text("Password").foregroundColor(placeholderTextColor)
        )
        .textFieldStyle(LoginTextFieldStyle())
        .focused($focusedField, equals: .password)
        .onSubmit {
            focusedField = nil
        }
    }
}
