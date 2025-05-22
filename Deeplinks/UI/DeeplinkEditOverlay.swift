//
//  DeeplinkEditOverlay.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2025. 05. 20..
//

import SwiftUI

private enum Field: Int, Hashable {
    case title, url
}

struct DeeplinkEditOverlay: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding public var deeplink: Deeplink
    @State private var isShowing = false
    @FocusState private var focusedField: Field?

    public var onSave: (() -> Void)
    public var onDismiss: (() -> Void)

    private let spacing: CGFloat = isIPad ? 24 : 16
    private let animationDuration = 0.25

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
                        .transition(.scale.animation(.easeInOut(duration: animationDuration)))
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
            text: $deeplink.title,
            prompt: Text("Name").foregroundColor(.placeholderText)
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
            text: $deeplink.url,
            prompt: Text("Url").foregroundColor(.placeholderText)
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
                onSave()
                closeOverlay()
            }, label: {
                Text("Save")
            })
            .buttonStyle(ActionButtonStyle())
            .disabled(deeplink.isEmpty)

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
            withAnimation(.easeInOut(duration: animationDuration)) {
                isShowing = false
            } completion: {
                onDismiss()
            }
        } else {
            withAnimation(.easeInOut(duration: animationDuration)) {
                isShowing = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                onDismiss()
            }
        }
    }
}
