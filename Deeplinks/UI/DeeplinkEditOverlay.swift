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
    @ObservedObject var viewModel: ContentViewModel
    @State private var isShowing = false
    @FocusState private var focusedField: Field?

    @State private var error: DeeplinkEditError?
    @State private var hasError: Bool = false

    public var willDismiss: (() -> Void)?
    public var onDismiss: (() -> Void)?

    private let spacing: CGFloat = isIPad ? 24 : 16

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

            VStack {
                Spacer()

                VStack {
                    if isShowing {
                        VStack(spacing: spacing) {
                            Text(viewModel.overlayState?.title ?? "")
                                .font(primary)
                                .foregroundColor(.white)

                            if let overlayState = viewModel.overlayState {

                                if let message = overlayState.message, !message.isEmpty {
                                    Text(message)
                                        .font(secondary)
                                        .foregroundColor(.lightGray)
                                }

                                switch overlayState {
                                case .section:
                                    sectionTitleTextField
                                case .create, .edit:
                                    VStack {
                                        linkTitleTextField
                                        linkUrlTextField
                                    }
                                case .delete:
                                    linkUrlTextField
                                        .disabled(true)
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
                        .frame(maxWidth: .infinity)
                        .background(Color.mainBackground)
                        .transition(.scale.animation(.easeInOut(duration: 0.1)))
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
            prompt: Text("Title").foregroundColor(.placeholderText),
            axis: .vertical
        )
        .lineLimit(3)
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
            prompt: Text("Url").foregroundColor(.placeholderText),
            axis: .vertical
        )
        .textFieldStyle(DeeplinkFieldStyle())
        .lineLimit(3)
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
            prompt: Text("Title").foregroundColor(.placeholderText),
            axis: .vertical
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
                trimWhitespaces()
                if let error = viewModel.validate() {
                    setError(error)
                } else {
                    if viewModel.hasChanged {
                        viewModel.update()
                    }
                    closeOverlay()
                }
            } label: {
                Text(viewModel.overlayState?.actionButtonText ?? "Save")
            }
            .buttonStyle(ActionButtonStyle())
            .disabled(isActionDisabled)

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
        withAnimation(.easeInOut(duration: 0.3)) {
            isShowing = false
        } completion: {
            onDismiss?()
        }
    }

    private func setError(_ error: DeeplinkEditError?) {
        guard self.error != error else { return }
        hasError = (error != nil)
        withAnimation(.smooth(duration: 0.1)) {
            self.error = error
        }
    }

    private var isActionDisabled: Bool {
        guard !hasError, let overlayState = viewModel.overlayState else {
            return true
        }

        switch overlayState {
        case .edit, .create:
            return viewModel.editingDeeplinkTitle.isEmpty || viewModel.editingDeeplinkUrl.isEmpty
        case .section:
            return viewModel.editingSectionTitle.isEmpty
        case .delete:
            return false
        }
    }

    private func trimWhitespaces() {
        viewModel.editingSectionTitle = viewModel.editingSectionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.editingDeeplinkTitle = viewModel.editingDeeplinkTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.editingDeeplinkUrl = viewModel.editingDeeplinkUrl.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
