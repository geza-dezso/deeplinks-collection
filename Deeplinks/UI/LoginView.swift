//
//  LoginView.swift
//  Deeplinks
//
//  Created by Geza Dezso on 11/04/2024.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: ContentViewModel

    @FocusState private var focusedField: FormField?

    private var isLoginDisabled: Bool {
        viewModel.user.isEmpty || viewModel.pwd.isEmpty
    }

    var body: some View {
        VStack(spacing: isTV ? 24 : isIPad ? 12 : 8) {
            usernameTextField

            passwordTextField

            Button(action: {
                focusedField = nil
                viewModel.onLogin()
            }, label: {
                Text("Login")
            })
            .buttonStyle(ActionButtonStyle())
            .disabled(isLoginDisabled)
            .padding(.top, 16)
        }
    }

    private var usernameTextField: some View {
        TextField(
            "",
            text: $viewModel.user,
            prompt: Text("User").foregroundColor(.placeholderText)
        )
        .textFieldStyle(LoginTextFieldStyle())
        .focused($focusedField, equals: .username)
        .onSubmit {
            focusedField = .password
        }
    }

    #if os(iOS)

    private var passwordTextField: some View {
        ToggleSecureField(
            title: "",
            text: $viewModel.pwd,
            prompt: Text("Password").foregroundColor(.placeholderText),
            focusedField: $focusedField,
            field: .password
        )
        .onSubmit {
            focusedField = nil
        }
    }

    #else

    private var passwordTextField: some View {
        SecureField(
            "",
            text: $viewModel.pwd,
            prompt: Text("Password").foregroundColor(.placeholderText)
        )
        .textFieldStyle(LoginTextFieldStyle())
        .focused($focusedField, equals: .password)
        .onSubmit {
            focusedField = nil
        }
    }

    #endif
}
