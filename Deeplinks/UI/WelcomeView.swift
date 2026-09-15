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
                    .padding(.bottom, 32)

                Group {
                    switch viewModel.state {

                    case .project:

                        Text("Create new project")
                            .font(primary)
                            .foregroundColor(.secondaryText)
                            .padding(.bottom, 24)

                        NewProjectView(viewModel: viewModel)

                    case .login:
                        LoginView(viewModel: viewModel)

                    case .fetching:
                        ProgressView()

                    default:
                        Spacer()
                    }
                }
                .frame(width: isTV ? 480 : isIPad ? 320 : 280)

                Spacer()

                #if os(iOS)
                if adminTools {
                    adminTapView
                }
                #endif
            }
            .offset(y: -32)
            .ignoresSafeArea(.keyboard)
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
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
