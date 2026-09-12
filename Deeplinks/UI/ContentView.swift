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
    @State private var shouldPresentAlert: Bool = false

    private let titlePadding: CGFloat = isTV ? 16 : isIPad ? 12 : 8
    private let scrollViewGradientHeight: CGFloat = isTV ? 48 : isIPad ? 32 : 24

    #if os(iOS)
    @State var swipeState: SwipeState = .untouched
    #endif

    var body: some View {

        ZStack {
            mainContentView
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            viewModel.onAppear()
        }
        .onChange(of: viewModel.alertState) {
            shouldPresentAlert = (viewModel.alertState != nil)
        }
        .alert("Error", isPresented: $shouldPresentAlert) {
            if let error = error {
                Button(error.alertButtonText, role: .cancel) {
                    viewModel.alertState = nil
                    viewModel.alertButtonAction(for: error)()
                }
            }
        } message: {
            Text(error?.message ?? "")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIScene.didEnterBackgroundNotification)) { _ in
            if viewModel.overlayState == nil {
                resetSwipeState()
            }
        }
    }

    @ViewBuilder
    private var mainContentView: some View {
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
                        ScrollViewReader { reader in
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: isTV ? 8 : isIPad ? 4 : 2) {
                                    ForEach(groups, id: \.self) { group in
                                        groupContent(for: group)
                                    }
                                    .padding(.horizontal, isTV ? 16 : 0)

                                    #if os(iOS)
                                    newSectionButton
                                    #endif
                                }
                                .padding(.top, 8)
                                .padding(.bottom, scrollViewGradientHeight - 8)
                            }
                            .padding(.horizontal, isTV ? 0 : 16)
                            .mask {
                                TopBottomGradientView(gradientHeight: scrollViewGradientHeight)
                            }
                            .onChange(of: viewModel.lastCreatedItemId) {
                                withAnimation {
                                    reader.scrollTo(viewModel.lastCreatedItemId, anchor: .bottom)
                                } completion: {
                                    viewModel.highlightedItemId = viewModel.lastCreatedItemId
                                    withAnimation(.linear(duration: 1.0)) {
                                        viewModel.highlightedItemId = nil
                                    }
                                }
                            }
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
            if viewModel.overlayState != nil {
                editOverlay
            }
            #endif
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
        if case let .error(error) = viewModel.alertState {
            return error
        }
        return nil
    }
}

#if os(iOS)

extension ContentView {

    @ViewBuilder
    private var userSection: some View {
        let iconSize: CGFloat = isIPad ? 40 : 32

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
                    .padding(.horizontal, isTV ? 24 : 16)
            }
            .background(Color.buttonBackground)
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
            if let deeplinks = group.deeplinks, !viewModel.isCollapsed(group) {
                ForEach(deeplinks, id: \.self) { deeplink in
                    DeeplinkItemView(
                        viewModel: viewModel,
                        swipeState: $swipeState,
                        deeplink: deeplink,
                        group: group,
                        padding: titlePadding
                    )
                    .id(viewModel.itemIdFor(groupTitle: group.title, deeplink: deeplink))
                }
            } else {
                Divider()
            }
        }
        .id(viewModel.itemIdFor(groupTitle: group.title))
    }

    @ViewBuilder
    private func sectionHeaderView(_ group: DeeplinkGroup) -> some View {
        HStack {
            Button {
                withAnimation(.smooth(duration: toggleDuration(for: group))) {
                    viewModel.toggle(group)
                }
            } label: {
                HStack {
                    Text(group.title)
                        .lineLimit(1)
                        .font(primary)
                        .foregroundColor(.secondaryText)
                        .padding(EdgeInsets(
                            top: 12, leading: titlePadding, bottom: 12, trailing: titlePadding
                        ))

                    Spacer()

                    Image(systemName: viewModel.isCollapsed(group) ? "chevron.down" : "chevron.up")
                        .foregroundColor(.white)
                }
            }

            Button {
                resetSwipeState()
                viewModel.overlayState = .create(for: group)
                withAnimation(.smooth(duration: toggleDuration(for: group))) {
                    viewModel.expand(group)
                }
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, titlePadding)
            }
        }
    }

    @ViewBuilder
    private var newSectionButton: some View {
        HStack {
            Button {
                viewModel.overlayState = .section
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, titlePadding)
            }
            .padding(EdgeInsets(top: 16, leading: 2, bottom: 2, trailing: 0))

            Spacer()
        }
    }

    @ViewBuilder
    private var editOverlay: some View {
        ZStack {
            DeeplinkEditOverlay(
                viewModel: viewModel,
                willDismiss: {
                    resetSwipeState()
                },
                onDismiss: {
                    viewModel.overlayState = nil
                }
            )
        }
    }

    private func resetSwipeState() {
        swipeState = .swiped(UUID())
    }

    private func toggleDuration(for group: DeeplinkGroup) -> TimeInterval {
        guard let deeplinks = group.deeplinks else { return 0 }
        return max(Double(deeplinks.count) / 50.0, 0.3)
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
                    DeeplinkItemView(viewModel: viewModel, deeplink: deeplink, group: group, padding: titlePadding)
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

    private func resetSwipeState() {}
}

#endif
