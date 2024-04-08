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

    var body: some View {

        ZStack {

            Image(uiImage: background ?? UIImage())
                .resizable()
                .edgesIgnoringSafeArea(.all)

            if viewModel.isLoading {
                ProgressView()
            }

            VStack {

                Text("Deeplinks")
                    .foregroundColor(.white)

                if let error = viewModel.error {
                    Text(error.displayText)
                } else {
                    if let deeplinks = viewModel.deeplinks {

                        List {
                            Section("Deeplinks") {
                                ForEach(deeplinks, id: \.self) { deeplink in
                                    DeeplinkItemView(title: deeplink, link: deeplink)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 1)
                                        .listRowInsets(EdgeInsets())
                                }
                            }
                            .font(isTV ? .system(.headline) : isIPad ? .system(size: 22) : .system(size: 16))
                            .foregroundColor(.white)
                        }
                        .contentBackground(.hidden)
                        .listStyle(GroupedListStyle())
                    }
                }

                Spacer()
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
}
