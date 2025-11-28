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

private enum DeeplinkEditError {
    case duplicate(isSection: Bool)

    var message: String {
        switch self {
        case .duplicate(isSection: true):
            return "A section with this name already exists."
        case .duplicate(isSection: false):
            return "A deeplink with this title and URL already exists."
        }
    }
}

struct DeeplinkEditOverlay: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var viewModel: ContentViewModel
    @State private var isShowing = false
    @FocusState private var focusedField: Field?

    @State var sectionTitle: String = ""
    @State var deeplinkTitle: String
    @State var deeplinkUrl: String
    @State private var error: DeeplinkEditError?
    @State private var hasError: Bool = false

    public var willDismiss: (() -> Void)?
    public var onDismiss: (() -> Void)?

    private let spacing: CGFloat = isIPad ? 24 : 16
    private let animationDuration = 0.3

    init(viewModel: ContentViewModel, willDismiss: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.willDismiss = willDismiss
        self.onDismiss = onDismiss

        switch viewModel.overlayState {

        case .edit(let deeplink, _):
            deeplinkTitle = deeplink.title
            deeplinkUrl = deeplink.url

        default:
            deeplinkTitle = ""
            deeplinkUrl = ""
        }
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
            text: $deeplinkTitle,
            prompt: Text("Title").foregroundColor(.placeholderText)
        )
        .textFieldStyle(DeeplinkFieldStyle())
        .focused($focusedField, equals: .title)
        .onChange(of: deeplinkTitle) {
            setError(nil)
        }
        .onSubmit {
            focusedField = .url
        }
    }

    private var linkUrlTextField: some View {
        TextField(
            "",
            text: $deeplinkUrl,
            prompt: Text("Url").foregroundColor(.placeholderText)
        )
        .textFieldStyle(DeeplinkFieldStyle())
        .focused($focusedField, equals: .url)
        .onChange(of: deeplinkUrl) {
            setError(nil)
        }
        .onSubmit {
            focusedField = nil
        }
    }

    private var sectionTitleTextField: some View {
        TextField(
            "",
            text: $sectionTitle,
            prompt: Text("Title").foregroundColor(.placeholderText)
        )
        .textFieldStyle(DeeplinkFieldStyle())
        .focused($focusedField, equals: .title)
        .onChange(of: sectionTitle) {
            setError(nil)
        }
        .onSubmit {
            focusedField = nil
        }
    }

    private var buttonsSection: some View {
        HStack {
            Button {
                if hasChanged {
                    if isValid {
                        update()
                        closeOverlay()
                    } else {
                        setError(.duplicate(isSection: viewModel.overlayState == .section))
                    }
                } else {
                    closeOverlay()
                }
            } label: {
                Text("Save")
            }
            .buttonStyle(ActionButtonStyle())
            .disabled(((deeplinkTitle.isEmpty || deeplinkUrl.isEmpty) && sectionTitle.isEmpty) || hasError)

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

    private func update() {
        switch viewModel.overlayState {

        case .edit(let deeplink, let group):
            let newDeeplink = Deeplink(title: deeplinkTitle, url: deeplinkUrl)
            viewModel.update(deeplink, with: newDeeplink, in: group)

        case .create(let group):
            let deeplink = Deeplink(title: deeplinkTitle, url: deeplinkUrl)
            viewModel.append(deeplink, to: group)

        case .section:
            viewModel.append(group: DeeplinkGroup(title: sectionTitle))

        default:
            break
        }
    }

    private var hasChanged: Bool {
        switch viewModel.overlayState {
        case .edit(let deeplink, _):
            return deeplink.title != deeplinkTitle || deeplink.url != deeplinkUrl
        default:
            return true
        }
    }

    private var isValid: Bool {
        switch viewModel.overlayState {

        case .edit(let deeplink, let group):
            return viewModel.checkValidity(
                for: Deeplink(title: deeplinkTitle, url: deeplinkUrl), oldValue: deeplink, in: group
            )

        case .create(let group):
            return viewModel.checkValidity(
                for: Deeplink(title: deeplinkTitle, url: deeplinkUrl), in: group
            )

        case .section:
            return viewModel.checkValidity(for: sectionTitle)

        default:
            return true
        }
    }

    private func setError(_ error: DeeplinkEditError?) {
        hasError = (error != nil)
        withAnimation(.smooth(duration: 0.1)) {
            self.error = error
        }
    }
}
