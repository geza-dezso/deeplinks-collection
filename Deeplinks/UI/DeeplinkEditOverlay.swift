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

    @State var sectionTitle: String = ""
    @State var deeplinkTitle: String
    @State var deeplinkUrl: String

    public var willDismiss: (() -> Void)?
    public var onDismiss: (() -> Void)?

    private let spacing: CGFloat = isIPad ? 24 : 16
    private let animationDuration = 0.3

    private var editedDeeplink: Deeplink?

    private var title: String {
        switch viewModel.overlayState {
        case .edit:
            return "Edit Deeplink"
        case .create:
            return "Create Deeplink"
        case .section:
            return "Create Section"
        default:
            return ""
        }
    }

    init(viewModel: ContentViewModel, willDismiss: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.willDismiss = willDismiss
        self.onDismiss = onDismiss

        switch viewModel.overlayState {

        case .edit(let deeplink, _):
            editedDeeplink = deeplink
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
                            ZStack {
                                VStack {
                                    VStack {
                                        Text(title)
                                            .font(primary)
                                            .foregroundColor(.white)
                                        Spacer()
                                            .frame(height: spacing)

                                        if case .section = viewModel.overlayState {
                                            sectionTitleTextField
                                        } else {
                                            linkTitleTextField
                                            linkUrlTextField
                                        }
                                    }

                                    Spacer()
                                        .frame(height: spacing)

                                    buttonsSection
                                }
                                .padding(spacing)
                                .background(Color.mainBackground)
                            }
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
        .onSubmit {
            focusedField = nil
        }
    }

    private var buttonsSection: some View {
        HStack {
            Button(action: {
                if let editedDeeplink, editedDeeplink.title == deeplinkTitle, editedDeeplink.url == deeplinkUrl {

                } else {
                    update()
                }
                closeOverlay()
            }, label: {
                Text("Save")
            })
            .buttonStyle(ActionButtonStyle())
            .disabled((deeplinkTitle.isEmpty || deeplinkUrl.isEmpty) && sectionTitle.isEmpty)

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
        if #available(iOS 17.0, *) {
            withAnimation(.easeInOut(duration: animationDuration)) {
                isShowing = false
            } completion: {
                onDismiss?()
            }
        } else {
            withAnimation(.easeInOut(duration: animationDuration)) {
                isShowing = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                onDismiss?()
            }
        }
    }

    private func update() {
        switch viewModel.overlayState {

        case .edit(var deeplink, let group):
            deeplink.title = deeplinkTitle
            deeplink.url = deeplinkUrl
            viewModel.update(deeplink, in: group)

        case .create(let group):
            let deeplink = Deeplink(title: deeplinkTitle, url: deeplinkUrl)
            viewModel.append(deeplink, to: group)

        case .section:
            viewModel.append(group: DeeplinkGroup(title: sectionTitle))

        default:
            break
        }
    }
}
