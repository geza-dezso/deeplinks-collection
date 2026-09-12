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
        viewModel.user.isEmpty || viewModel.pwd.isEmpty || viewModel.confirmPwd.isEmpty
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
            prompt: Text("Username").foregroundColor(.placeholderText)
        )
        .textFieldStyle(LoginTextFieldStyle())
        .focused($focusedField, equals: .username)
        .onSubmit {
            focusedField = .password
        }
    }

    private var passwordTextField: some View {
        SecureField(
            "",
            text: $viewModel.pwd,
            prompt: Text("Password").foregroundColor(.placeholderText)
        )
        .textFieldStyle(LoginTextFieldStyle())
        .focused($focusedField, equals: .password)
        .onSubmit {
            focusedField = .confirmPassword
        }
    }

    private var confirmPasswordTextField: some View {
        SecureField(
            "",
            text: $viewModel.confirmPwd,
            prompt: Text("Confirm password").foregroundColor(.placeholderText)
        )
        .textFieldStyle(LoginTextFieldStyle())
        .focused($focusedField, equals: .confirmPassword)
        .onSubmit {
            focusedField = nil
        }
    }
}
