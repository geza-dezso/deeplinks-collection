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

    var body: some View {

        ZStack {

            if viewModel.isLoading {
                ActivityIndicator()
            }

            VStack {

                Text("Deeplinks")

                if let error = viewModel.error {
                    Text(error.displayText)
                } else {
                    if let deeplinks = viewModel.deeplinks {
                        VStack {
                            List {
                                ForEach(deeplinks, id: \.self) { deeplink in
                                    Link(deeplink, destination: URL(string: deeplink)!)
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .onAppear {
                viewModel.onAppear()
            }
        }
    }
}
