//
//  NewProjectView.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2026. 08. 30..
//

import SwiftUI

private enum Field: Int, Hashable {
    case username, password, confirmPassword
}

struct NewProjectView: View {
    @ObservedObject var viewModel: ContentViewModel

    @FocusState private var focusedField: Field?

    private var isCreateDisabled: Bool {
        viewModel.user.count < 3 ||
        viewModel.pwd.count < 3 ||
        viewModel.confirmPwd.count < 3 ||
        viewModel.pwd != viewModel.confirmPwd
    }

    var body: some View {
        VStack(spacing: isIPad ? 12: 8) {
            usernameTextField

            passwordTextField

            confirmPasswordTextField

            HStack(spacing: isIPad ? 12: 8) {
                Button(action: {
                    focusedField = nil
                    // handle create action
                }, label: {
                    Text("Create")
                })
                .buttonStyle(ActionButtonStyle())
                .disabled(isCreateDisabled)

                Button(action: {
                    focusedField = nil
                    viewModel.onEnterCredentials()
                }, label: {
                    Text("Cancel")
                })
                .buttonStyle(ActionButtonStyle())
            }
            .padding(.top, 16)
        }
    }

    private var usernameTextField: some View {
        TextField(
            "",
            text: $viewModel.user,
            prompt: Text("User (min. 3 chars)").foregroundColor(.placeholderText)
        )
        .textFieldStyle(LoginTextFieldStyle())
        .focused($focusedField, equals: .username)
        .onSubmit {
            focusedField = .password
        }
    }

    private var passwordTextField: some View {
        ToggleSecureField(
            title: "",
            text: $viewModel.pwd,
            prompt: Text("Password (min. 3 chars)").foregroundColor(.placeholderText),
            focusedField: $focusedField,
            field: .password,
        )
        .onSubmit {
            focusedField = .confirmPassword
        }
    }

    private var confirmPasswordTextField: some View {
        ToggleSecureField(
            title: "",
            text: $viewModel.confirmPwd,
            prompt: Text("Confirm password").foregroundColor(.placeholderText),
            focusedField: $focusedField,
            field: .confirmPassword,
        )
        .onSubmit {
            focusedField = nil
        }
    }
}
