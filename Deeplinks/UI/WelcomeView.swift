//
//  WelcomeView.swift
//  Deeplinks
//
//  Created by Geza Dezso on 11/04/2024.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: ContentViewModel

    #if os(iOS)
    @AppStorage("admin_tools") private var adminTools: Bool = false
    #endif

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

            VStack(spacing: 0) {

                Spacer()

                Text("Deeplinks Collection")
                    .font(headline)
                    .bold()
                    .foregroundColor(.primaryText)

                Group {
                    if viewModel.state == .login {
                        LoginView(viewModel: viewModel)

                    } else if viewModel.state == .fetching {
                        ProgressView()

                    } else {
                        Spacer()
                    }
                }
                .frame(width: isTV ? 480 : isIPad ? 320 : 280, height: isTV ? 400 : isIPad ? 280 : 200)

                Spacer()

                #if os(iOS)
                if adminTools {
                    adminTapView
                }
                #endif
            }
            .offset(y: -32)
            .ignoresSafeArea(.keyboard)
        }
    }

    #if os(iOS)
    private var adminTapView: some View {
        MultipleTapView(numberOfTaps: 3) {
            viewModel.onNewProject()
        }
        .frame(height: 100)
    }
    #endif
}
