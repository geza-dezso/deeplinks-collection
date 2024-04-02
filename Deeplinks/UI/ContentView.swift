//
//  ContentView.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 18/03/2024.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        VStack {

            Text("Title")

            if let error = viewModel.error {
                Text(error.displayText)
            }

            else if viewModel.isLoading {
                // loading indicator
            }

            else {
                if let deeplinks = viewModel.deeplinks {
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(deeplinks, id: \.self) { deeplink in
                            Text(deeplink)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}
