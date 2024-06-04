//
//  ContentView.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 18/03/2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @ObservedObject var viewModel: ContentViewModel
    @State private var isLogoutDisabled: Bool = true

    private let padding: CGFloat = isTV ? 16 : isIPad ? 12 : 8

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
                                VStack(spacing: 2) {
                                    ForEach(groups, id: \.self) { group in
                                        Section(header: sectionHeaderView(group.title)) {
                                            if let deeplinks = group.deeplinks {
                                                ForEach(deeplinks, id: \.self) { deeplink in
                                                    DeeplinkItemView(title: deeplink.title, link: deeplink.url)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom, 16)
                            }
                            .padding(.horizontal, 16)
                            .listStyle(GroupedListStyle())
                            .mask {
                                scrollViewGradient
                            }
                        }

                        Spacer()

                        if !isTV {
                            logoutButton
                                .padding(.vertical, 16)
                        }
                    }
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
                Button(viewModel.alertButtonText(for: error), role: .cancel) {
                    viewModel.shouldPresentErrorAlert = false
                    viewModel.alertButtonAction(for: error)()
                }
            }
        }
        message: {
            Text(error?.message ?? "")
        }
    }

    @ViewBuilder
    private var titleView: some View {
        let iconSize: CGFloat = isTV ? 64 : 32

        HStack {
            Text("Deeplinks Collection")
                .font(primary)
                .bold()
                .foregroundColor(.primaryText)

            Spacer()

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

            if isTV {
                logoutButton
                    .disabled(isLogoutDisabled)
            }
        }
        .padding(.horizontal, padding)
        .padding(.top, 16)
    }

    @ViewBuilder
    private var logoutButton: some View {
        Button(action: {
            viewModel.onLogout()
        }, label: {
            Text("Logout")
        })
        .buttonStyle(ActionButtonStyle())
    }

    @ViewBuilder
    private func sectionHeaderView(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(primary)
                .foregroundColor(.secondaryText)
                .padding(EdgeInsets(top: 16, leading: padding, bottom: 16, trailing: padding))
            Spacer()
        }
    }

    @ViewBuilder
    private var scrollViewGradient: some View {

        VStack(spacing: 0) {
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0), .black]),
                startPoint: UnitPoint(x: 0, y: 0),
                endPoint: UnitPoint(x: 0, y: 1)
            )
            .frame(height: 24)

            Color.black
                .frame(maxHeight: .infinity)

            LinearGradient(
                gradient: Gradient(colors: [.black, .black.opacity(0)]),
                startPoint: UnitPoint(x: 0, y: 0),
                endPoint: UnitPoint(x: 0, y: 1)
            )
            .frame(height: 24)
        }
    }

    private func enableLogout() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLogoutDisabled = false
        }
    }

    private var error: DeeplinkError? {
        if case let .error(error) = viewModel.state {
            return error
        }
        return nil
    }
}
