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

    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
        // only for iOS 15
        UITableView.appearance().backgroundColor = .clear
    }

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

                            List {
                                ForEach(groups, id: \.self) { group in
                                    Section(header: sectionHeaderView(group.title)) {
                                        if let deeplinks = group.deeplinks {
                                            ForEach(deeplinks, id: \.self) { deeplink in
                                                DeeplinkItemView(title: deeplink.title, link: deeplink.url)
                                                    .padding(.vertical, 1)
                                            }
                                        }
                                    }
                                    .listRowInsets(EdgeInsets())
                                }
                                .padding(.horizontal, 16)
                            }
                            .contentBackground(.hidden)
                            .listStyle(GroupedListStyle())
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
        .padding(.vertical, 16)
    }

    @ViewBuilder
    private var logoutButton: some View {
        Button(action: {
            viewModel.onAppear()
        }, label: {
            Text("Logout")
        })
        .buttonStyle(ActionButtonStyle())
    }

    @ViewBuilder
    private func sectionHeaderView(_ title: String) -> some View {
        Text(title)
            .font(primary)
            .foregroundColor(.secondaryText)
            .padding(EdgeInsets(top: 0, leading: padding, bottom: 16, trailing: padding))
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
