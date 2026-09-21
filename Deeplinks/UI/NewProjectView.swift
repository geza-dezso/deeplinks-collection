//
//  NewProjectView.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2026. 08. 30..
//

import SwiftUI

struct NewProjectView: View {
    @ObservedObject var viewModel: ContentViewModel

    @FocusState private var focusedField: FormField?

    private var isCreateDisabled: Bool {
        viewModel.user.count < 3 ||
        viewModel.newPwd.count < 3 ||
        viewModel.confirmPwd.count < 3 ||
        viewModel.newPwd != viewModel.confirmPwd
    }

    var body: some View {
        VStack(spacing: isIPad ? 12: 8) {
            usernameTextField

            passwordTextField

            confirmPasswordTextField

            HStack(spacing: isIPad ? 12: 8) {
                Button(action: {
                    focusedField = nil
                    viewModel.onCreateProject()
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
            focusedField = .newPassword
        }
    }

    private var passwordTextField: some View {
        ToggleSecureField(
            title: "",
            text: $viewModel.newPwd,
            prompt: Text("Password (min. 3 chars)").foregroundColor(.placeholderText),
            focusedField: $focusedField,
            field: .newPassword,
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
