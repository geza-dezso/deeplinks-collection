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

    @State private var isPortrait = false

    private let padding: CGFloat = isTV ? 16 : isIPad ? 12 : 8

    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
        // only for iOS 15
        UITableView.appearance().backgroundColor = .clear
    }

    private var background: UIImage? {
        if isIPhone {
            return UIImage(named: "Back_iPhone")
        } else if isIPad && isPortrait {
            return UIImage(named: "Back_iPad_portrait")
        } else if isIPad && !isPortrait {
            return UIImage(named: "Back_iPad_landscape")
        } else if isTV {
            return UIImage(named: "Back_TV")
        }
        return nil
    }

    private var backgroundColor = Color(red: 0.0, green: 0.15, blue: 0.20)

    var body: some View {

        ZStack {

            if viewModel.state != .ready {
                welcomeView

            } else {

                ZStack {
                    backgroundColor
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
                    }
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
            isPortrait = UIApplication.shared.isPortrait
        }
        .onDeviceRotation { _ in
            isPortrait = UIApplication.shared.isPortrait
        }
    }

    @ViewBuilder
    private var welcomeView: some View {
        ZStack {
            Image(uiImage: background ?? UIImage())
                .resizable()
                .edgesIgnoringSafeArea(.all)

            if viewModel.state == .login {
                loginView

            } else if viewModel.state == .fetching {
                ProgressView()

            } else if case .error(let error) = viewModel.state {
                // handle error
            }
        }
    }

    @ViewBuilder
    private var loginView: some View {
        Button(action: {
            viewModel.onLogin()
        }, label: {
            Text("Login")
        })
    }

    @ViewBuilder
    private var titleView: some View {
        let iconSize: CGFloat = isTV ? 64 : 32

        HStack {
            Text("Deeplinks Collection")
                .font(primary)
                .bold()
                .foregroundColor(.white)

            Spacer()

            HStack(spacing: 0) {
                Image(uiImage: UIImage(named: "UserIcon")!)
                    .resizable()
                    .frame(width: iconSize, height: iconSize)

                Text(viewModel.user)
                    .font(primary)
                    .foregroundColor(.white)
                    .padding(.horizontal, isTV ? 24 : 12)
            }
            .background(Color.white.opacity(0.1))
            .cornerRadius(iconSize/2)
        }
        .padding(.horizontal, padding)
        .padding(.vertical, 16)
    }

    @ViewBuilder
    private func sectionHeaderView(_ title: String) -> some View {
        Text(title)
            .font(primary)
            .foregroundColor(.gray)
            .padding(EdgeInsets(top: 0, leading: padding, bottom: 16, trailing: padding))
    }
}
