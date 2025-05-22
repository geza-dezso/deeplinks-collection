//
//  ContentView.swift
//  Deeplinks
//
//  Created by Geza Dezso on 18/03/2024.
//

import SwiftUI
#if os(iOS)
import SwipeActions
#endif

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @ObservedObject var viewModel: ContentViewModel
    @State private var isLogoutDisabled: Bool = true
    @State private var isPresentingLogoutConfirmation: Bool = false

    private let titlePadding: CGFloat = isTV ? 16 : isIPad ? 12 : 8
    private let scrollViewGradientHeight: CGFloat = isTV ? 48 : isIPad ? 32 : 24

    #if os(iOS)
    @State var swipeState: SwipeState = .untouched
    #endif

    var body: some View {

        ZStack {

            if viewModel.state != .ready {
                WelcomeView(viewModel: viewModel)

            } else {

                ZStack {
                    Color.mainBackground
                        .edgesIgnoringSafeArea(.all)

                    VStack {

                        titleView
                            .padding(.horizontal, 16)

                        if let groups = viewModel.deeplinkGroups {

                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: isTV ? 8 : isIPad ? 4 : 2) {
                                    ForEach(groups, id: \.self) { group in
                                        groupContent(for: group)
                                    }
                                    .padding(.horizontal, isTV ? 16 : 0)
                                }
                            }
                            .padding(.top, 8)
                            .padding(.horizontal, isTV ? 0 : 16)
                            .padding(.bottom, scrollViewGradientHeight - 8)
                            .mask {
                                TopBottomGradientView(gradientHeight: scrollViewGradientHeight)
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, isIPad ? 24 : 0)
                    .padding(.vertical, isTV ? 0 : 8)
                    .onAppear {
                        enableLogout()
                    }
                }
                #if os(iOS)
                .fullScreenCover(isPresented: $viewModel.shouldPresentEditOverlay) {
                    editOverlay
                }
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
                #endif
            }
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            viewModel.onAppear()
        }
        .alert("Error", isPresented: $viewModel.shouldPresentErrorAlert) {
            if let error = error {
                Button(error.buttonText, role: .cancel) {
                    viewModel.overlayState = nil
                    viewModel.alertButtonAction(for: error)()
                }
            }
        } message: {
            Text(error?.message ?? "")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIScene.didEnterBackgroundNotification)) { _ in
            if viewModel.overlayState == nil {
                resetEditing()
            }
        }
    }

    @ViewBuilder
    private var titleView: some View {

        HStack {
            Text("Deeplinks Collection")
                .font(primary)
                .bold()
                .foregroundColor(.primaryText)

            Spacer()

            userSection
        }
        .padding(.horizontal, titlePadding)
        .padding(.top, 16)
    }

    private func enableLogout() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLogoutDisabled = false
        }
    }

    private var error: DeeplinkError? {
        if case let .error(error) = viewModel.overlayState {
            return error
        }
        return nil
    }
}

#if os(iOS)

extension ContentView {

    @ViewBuilder
    private var userSection: some View {
        let iconSize: CGFloat = 32

        Button(action: {
            isPresentingLogoutConfirmation = true
        }, label: {
            HStack(spacing: 0) {
                Image(uiImage: UIImage(named: "UserIcon")!)
                    .resizable()
                    .frame(width: iconSize, height: iconSize)

                Text(viewModel.user)
                    .font(primary)
                    .foregroundColor(.primaryText)
                    .padding(.horizontal, isTV ? 24 : 12)
            }
            .background(Color.itemBackground)
            .cornerRadius(iconSize/2)
            .overlay(
                RoundedRectangle(cornerRadius: iconSize/2)
                    .stroke(Color.lightGray, lineWidth: 1)
            )
        })
        .confirmationDialog("Logout",
            isPresented: $isPresentingLogoutConfirmation) {
            Button("Logout") {
                viewModel.onLogout()
            }
        }
    }

    @ViewBuilder
    private func groupContent(for group: DeeplinkGroup) -> some View {
        Section(header: sectionHeaderView(group)) {
            if let deeplinks = group.deeplinks {
                ForEach(deeplinks, id: \.self) { deeplink in
                    DeeplinkItemView(
                        viewModel: viewModel,
                        swipeState: $swipeState,
                        deeplink: deeplink,
                        padding: titlePadding
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func sectionHeaderView(_ group: DeeplinkGroup) -> some View {
        HStack {
            Text(group.title)
                .font(primary)
                .foregroundColor(.secondaryText)
                .padding(EdgeInsets(
                    top: 12, leading: titlePadding, bottom: 12, trailing: titlePadding
                ))

            Spacer()

            Button {
                viewModel.overlayState = .create(for: group.id)
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, titlePadding)
            }
        }
    }

    @ViewBuilder
    private var editOverlay: some View {
        ZStack {
            DeeplinkEditOverlay(
                deeplink: $viewModel.editingItem,
                onSave: {
                    viewModel.update()
                },
                onDismiss: {
                    viewModel.overlayState = nil
                    resetEditing()
                }
            )
            .overlayBackground(.black.opacity(0.5))
        }
    }

    private func resetEditing() {
        swipeState = .swiped(UUID())
        viewModel.editingItem = Deeplink(title: "", url: "")
    }
}

#else

extension ContentView {

    @ViewBuilder
    private var userSection: some View {
        let iconSize: CGFloat = 64

        HStack(spacing: 0) {
            Image(uiImage: UIImage(named: "UserIcon")!)
                .resizable()
                .frame(width: iconSize, height: iconSize)

            Text(viewModel.user)
                .font(primary)
                .foregroundColor(.primaryText)
                .padding(.horizontal, isTV ? 24 : 12)
        }
        .background(Color.itemBackground)
        .cornerRadius(iconSize/2)

        Button(action: {
            viewModel.onLogout()
        }, label: {
            Text("Logout")
        })
        .buttonStyle(ActionButtonStyle())
        .disabled(isLogoutDisabled)
    }

    @ViewBuilder
    private func groupContent(for group: DeeplinkGroup) -> some View {
        Section(header: sectionHeaderView(group.title)) {
            if let deeplinks = group.deeplinks {
                ForEach(deeplinks, id: \.self) { deeplink in
                    DeeplinkItemView(deeplink: deeplink, padding: titlePadding)
                }
            }
        }
    }

    @ViewBuilder
    private func sectionHeaderView(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(primary)
                .foregroundColor(.secondaryText)
                .padding(EdgeInsets(
                    top: 20, leading: titlePadding, bottom: 20, trailing: titlePadding
                ))
            Spacer()
        }
    }

    private func resetEditing() {}
}

#endif
