//
//  DeeplinkOverlay.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2025. 05. 20..
//

import SwiftUI

private enum Field: Int, Hashable {
    case title, url
}

struct DeeplinkOverlay: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State public var deeplinkTitle: String = ""
    @State public var deeplinkUrl: String = ""
    @State private var isShowing = false
    @FocusState private var focusedField: Field?

    public var onDismiss: (() -> Void)

    private let spacing: CGFloat = isIPad ? 24 : 16

    var body: some View {
        GeometryReader { _ in
            VStack {
                Spacer()

                VStack {
                    if isShowing {
                        VStack {
                            VStack {
                                Text("Edit Deeplink")
                                    .font(primary)
                                    .foregroundColor(.white)
                                Spacer()
                                    .frame(height: spacing)
                                titleTextField
                                urlTextField
                            }

                            Spacer()
                                .frame(height: spacing)

                            buttonsSection
                        }
                        .padding(spacing)
                        .background(Color.mainBackground)
                        .transition(.scale.animation(.easeInOut))
                    }
                }
                .cornerRadius(8)
                .padding(.horizontal, isIPad ? 16 : 8)
                .offset(y: isIPad ? (horizontalSizeClass == .compact ? -128 : -192) : -64)

                Spacer()
            }
            .onAppear {
                isShowing = true
                focusedField = .title
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    private var titleTextField: some View {
        TextField(
            "",
            text: $deeplinkTitle,
            prompt: Text("Name").foregroundColor(.white)
        )
        .textFieldStyle(DeeplinkFieldStyle())
        .focused($focusedField, equals: .title)
        .onSubmit {
            focusedField = .url
        }
    }

    private var urlTextField: some View {
        TextField(
            "",
            text: $deeplinkUrl,
            prompt: Text("Url").foregroundColor(.white)
        )
        .textFieldStyle(DeeplinkFieldStyle())
        .focused($focusedField, equals: .url)
        .onSubmit {
            focusedField = nil
        }
    }

    private var buttonsSection: some View {
        HStack {
            Button(action: {
                // save action
                closeOverlay()
            }, label: {
                Text("Save")
            })
            .buttonStyle(ActionButtonStyle())

            Spacer()
                .frame(width: 32)

            Button(action: {
                closeOverlay()
            }, label: {
                Text("Cancel")
            })
            .buttonStyle(ActionButtonStyle())
        }
    }

    private func closeOverlay() {
        focusedField = nil
        if #available(iOS 17.0, *) {
            withAnimation {
                isShowing = false
            } completion: {
                onDismiss()
            }
        } else {
            withAnimation {
                isShowing = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onDismiss()
            }
        }
    }
}
