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
            prompt: Text("Password").foregroundColor(.placeholderText)
        )
        .focused($focusedField, equals: .password)
        .onSubmit {
            focusedField = .password
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
