//
//  ToggleSecureField.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2026. 09. 14..
//

import SwiftUI

struct ToggleSecureField: View {
    private enum InputField: Hashable {
        case secure
        case revealed
    }

    let title: String
    @Binding var text: String
    var prompt: Text?
    @FocusState.Binding var focusedField: FormField?
    let field: FormField

    @FocusState private var focusedInput: InputField?
    @State private var isShowingPassword = false

    @State private var shouldPreserveSecureValue = false

    private var isFocused: Binding<Bool> {
        Binding(
            get: { focusedField == field },
            set: { focusedField = $0 ? field : nil }
        )
    }

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
                    .simultaneousGesture(TapGesture().onEnded {
                        shouldPreserveSecureValue = true
                    })
                    .onChange(of: text) { oldValue, newValue in
                        if shouldPreserveSecureValue {
                            text = oldValue + newValue
                            shouldPreserveSecureValue = false
                        }
                    }
                    .onChange(of: isShowingPassword) {
                        shouldPreserveSecureValue = !isShowingPassword
                    }
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
            updateInputFocus(for: isFocused.wrappedValue)
        }
        .onChange(of: isFocused.wrappedValue) { _, newValue in
            updateInputFocus(for: newValue)
        }
        .onChange(of: focusedInput) { _, newValue in
            guard newValue != nil else {
                if isFocused.wrappedValue {
                    isFocused.wrappedValue = false
                }
                return
            }
            isFocused.wrappedValue = true
        }
    }

    private func togglePasswordVisibility() {
        isShowingPassword.toggle()
        focusedInput = isShowingPassword ? .revealed : .secure
        isFocused.wrappedValue = true
    }

    private func updateInputFocus(for isFocused: Bool) {
        guard isFocused else {
            focusedInput = nil
            return
        }
        focusedInput = isShowingPassword ? .revealed : .secure
    }
}
