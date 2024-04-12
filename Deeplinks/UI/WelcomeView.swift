//
//  WelcomeView.swift
//  Deeplinks
//
//  Created by Geza Dezso on 11/04/2024.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: ContentViewModel

    private var background: UIImage? {
        if isTV {
            return UIImage(named: "Back_TV")
        } else {
            return UIImage(named: "Back_mobile")
        }
    }

    var body: some View {
        ZStack {
            Image(uiImage: background ?? UIImage())
                .resizable()
                .edgesIgnoringSafeArea(.all)

            VStack {

                Spacer()

                Text("Deeplinks Collection")
                    .font(headline)
                    .bold()
                    .foregroundColor(.white)

                Group {
                    if viewModel.state == .login {
                        LoginView(viewModel: viewModel)

                    } else if viewModel.state == .fetching {
                        ProgressView()

                    } else if case .error(let error) = viewModel.state {
                        Text(error.displayText)
                            .font(primary)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: isIPad ? 320 : 280, height: isIPad ? 240 : 180)

                Spacer()
            }
            .offset(y: -32)
            .ignoresSafeArea(.keyboard)
        }
    }
}
