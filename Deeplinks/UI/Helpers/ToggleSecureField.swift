//
//  ToggleSecureField.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2026. 09. 14..
//

import SwiftUI

struct ToggleSecureField<Field: Hashable>: View {
    private enum InputField: Hashable {
        case secure
        case revealed
    }

    let title: String
    @Binding var text: String
    var prompt: Text?
    @FocusState.Binding var focusedField: Field?
    let field: Field

    @FocusState private var focusedInput: InputField?
    @State private var isShowingPassword = false

    var body: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {

                TextField(title, text: $text, prompt: prompt)
                    .textFieldStyle(SecureTextFieldStyle())
                    .focused($focusedInput, equals: .revealed)
                    .opacity(isShowingPassword ? 1 : 0)
                    .allowsHitTesting(isShowingPassword)
                    .accessibilityHidden(!isShowingPassword)

                SecureField(title, text: $text, prompt: prompt)
                    .textFieldStyle(SecureTextFieldStyle())
                    .focused($focusedInput, equals: .secure)
                    .opacity(isShowingPassword ? 0 : 1)
                    .allowsHitTesting(!isShowingPassword)
                    .accessibilityHidden(isShowingPassword)
            }

            Button(action: togglePasswordVisibility, label: {
                Image(systemName: isShowingPassword ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            })
            .padding(.horizontal, 8)
        }
        .background(Color.itemBackground)
        .cornerRadius(4.0)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(.gray, lineWidth: 1)
        )
        .onAppear {
            updateInputFocus(for: focusedField)
        }
        .onChange(of: focusedField) { _, newValue in
            updateInputFocus(for: newValue)
        }
        .onChange(of: focusedInput) { _, newValue in
            guard newValue != nil else {
                if focusedField == field {
                    focusedField = nil
                }
                return
            }
            focusedField = field
        }
    }

    private func togglePasswordVisibility() {
        isShowingPassword.toggle()
        focusedInput = isShowingPassword ? .revealed : .secure
        focusedField = field
    }

    private func updateInputFocus(for focusedField: Field?) {
        guard focusedField == field else {
            focusedInput = nil
            return
        }
        focusedInput = isShowingPassword ? .revealed : .secure
    }
}
