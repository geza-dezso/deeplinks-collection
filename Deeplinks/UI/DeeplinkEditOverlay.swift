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

private extension DeeplinkUpdateError {
    var message: String {
        switch self {
        case .duplicate(isSection: true):
            return "A section with this name already exists."
        case .duplicate(isSection: false):
            return "A deeplink with this title and URL already exists."
        case .invalidUrl:
            return "This doesn't seem like a valid deeplink."
        }
    }
}

struct DeeplinkEditOverlay: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var viewModel: ContentViewModel
    @State private var isShowing = false
    @FocusState private var focusedField: Field?

    @State private var error: DeeplinkUpdateError?
    @State private var hasError: Bool = false

    public var willDismiss: (() -> Void)?
    public var onDismiss: (() -> Void)?

    private let spacing: CGFloat = isIPad ? 24 : 16
    private let animationDuration = 0.3

    init(viewModel: ContentViewModel, willDismiss: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.willDismiss = willDismiss
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack {

            if isShowing {
                Color.black.opacity(0.5)
                    .ignoresSafeArea(.all)
            }

            GeometryReader { _ in
                VStack {
                    Spacer()

                    VStack {
                        if isShowing {
                            VStack(spacing: spacing) {
                                Text(viewModel.overlayState?.title ?? "")
                                    .font(primary)
                                    .foregroundColor(.white)

                                if case .section = viewModel.overlayState {
                                    sectionTitleTextField
                                } else {
                                    VStack {
                                        linkTitleTextField
                                        linkUrlTextField
                                    }
                                }

                                if let error {
                                    withAnimation(.smooth(duration: 0.1)) {
                                        Text(error.message)
                                            .font(secondary)
                                            .foregroundColor(.lightGray)
                                    }
                                }

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

            if viewModel.isUpdating {
                Color.black.opacity(0.3)
                    .ignoresSafeArea(.all)
                ProgressView()
                    .tint(.white)
                    .offset(y: isIPad ? (horizontalSizeClass == .compact ? -128 : -192) : -64)
            }
        }
    }

    private var linkTitleTextField: some View {
        TextField(
            "",
            text: $viewModel.editingDeeplinkTitle,
            prompt: Text("Title").foregroundColor(.placeholderText)
        )
        .textFieldStyle(DeeplinkFieldStyle())
        .focused($focusedField, equals: .title)
        .onChange(of: viewModel.editingDeeplinkTitle) {
            setError(nil)
        }
        .onSubmit {
            focusedField = .url
        }
    }

    private var linkUrlTextField: some View {
        TextField(
            "",
            text: $viewModel.editingDeeplinkUrl,
            prompt: Text("Url").foregroundColor(.placeholderText)
        )
        .textFieldStyle(DeeplinkFieldStyle())
        .focused($focusedField, equals: .url)
        .onChange(of: viewModel.editingDeeplinkUrl) {
            setError(nil)
        }
        .onSubmit {
            focusedField = nil
        }
    }

    private var sectionTitleTextField: some View {
        TextField(
            "",
            text: $viewModel.editingSectionTitle,
            prompt: Text("Title").foregroundColor(.placeholderText)
        )
        .textFieldStyle(DeeplinkFieldStyle())
        .focused($focusedField, equals: .title)
        .onChange(of: viewModel.editingSectionTitle) {
            setError(nil)
        }
        .onSubmit {
            focusedField = nil
        }
    }

    private var buttonsSection: some View {
        HStack {
            Button {
                if viewModel.hasChanged {
                    if let error = viewModel.validate() {
                        setError(error)
                    } else {
                        viewModel.update()
                        closeOverlay()
                    }
                } else {
                    closeOverlay()
                }
            } label: {
                Text("Save")
            }
            .buttonStyle(ActionButtonStyle())
            .disabled(isSaveDisabled)

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
        willDismiss?()
        withAnimation(.easeInOut(duration: animationDuration)) {
            isShowing = false
        } completion: {
            onDismiss?()
        }
    }

    private func setError(_ error: DeeplinkUpdateError?) {
        guard self.error != error else { return }
        DispatchQueue.main.async {
            hasError = (error != nil)
            withAnimation(.smooth(duration: 0.1)) {
                self.error = error
            }
        }
    }

    private var isSaveDisabled: Bool {
        guard !hasError else { return true }
        return
            (viewModel.editingDeeplinkTitle.isEmpty || viewModel.editingDeeplinkUrl.isEmpty)
            && viewModel.editingSectionTitle.isEmpty
    }
}
