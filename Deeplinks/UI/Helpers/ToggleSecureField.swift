//
//  ToggleSecureField.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2026. 09. 14..
//

import SwiftUI

struct ToggleSecureField: View {
    let title: String
    @Binding var text: String
    var prompt: Text?
    @State private var isShowingPassword = false

    var body: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                TextField(title, text: $text, prompt: prompt)
                    .textFieldStyle(SecureTextFieldStyle())
                    .opacity(isShowingPassword ? 1 : 0)

                SecureField(title, text: $text, prompt: prompt)
                    .textFieldStyle(SecureTextFieldStyle())
                    .opacity(isShowingPassword ? 0 : 1)
            }

            Button(action: {
                isShowingPassword.toggle()
            }, label: {
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
    }
}
