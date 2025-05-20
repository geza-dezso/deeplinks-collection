//
//  ContentView.swift
//  Deeplinks Collection
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
                    #if os(iOS)
                    swipeState = .swiped(UUID())
                    #endif
                }
            }
        } message: {
            Text(error?.message ?? "")
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

    @ViewBuilder
    private var mobileUserSection: some View {
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
    private func sectionHeaderView(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(primary)
                .foregroundColor(.secondaryText)
                .padding(EdgeInsets(
                    top: isTV ? 20 : 12, leading: titlePadding, bottom: isTV ? 20 : 12, trailing: titlePadding
                ))
            Spacer()
        }
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
        Section(header: sectionHeaderView(group.title)) {
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
}

#endif
