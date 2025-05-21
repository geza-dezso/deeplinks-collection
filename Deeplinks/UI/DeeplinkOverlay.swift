//
//  DeeplinkOverlay.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2025. 05. 20..
//

import SwiftUI

struct DeeplinkOverlay: View {
    @State public var deeplinkName: String = ""
    @State public var deeplinkUrl: String = ""
    @State private var isShowing = false

    public var onDismiss: (() -> Void)

    var body: some View {
        ZStack {
            if isShowing {
                VStack {
                    VStack {
                        Text("Edit Deeplink")
                            .foregroundColor(.white)
                        Spacer()
                            .frame(height: 24)
                        nameTextField
                        linkTextField
                    }

                    Spacer()
                        .frame(height: 24)

                    buttonsSection
                }
                .padding(24)
                .background(Color.mainBackground)
                .transition(.scale.animation(.easeInOut))
            }
        }
        .onAppear { isShowing = true }
        .onDisappear { isShowing = false }
    }

    private var nameTextField: some View {
        TextField(
            "",
            text: $deeplinkName,
            prompt: Text("Name").foregroundColor(.white)
        )
        .textFieldStyle(DeeplinkFieldStyle())
        .onSubmit {
            //
        }
    }

    private var linkTextField: some View {
        TextField(
            "",
            text: $deeplinkUrl,
            prompt: Text("Url").foregroundColor(.white)
        )
        .textFieldStyle(DeeplinkFieldStyle())
        .onSubmit {
            //
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
