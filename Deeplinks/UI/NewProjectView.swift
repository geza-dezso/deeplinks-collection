//
//  NewProjectView.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2026. 08. 30..
//

import SwiftUI

struct NewProjectView: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "Back_mobile") ?? UIImage())
                .resizable()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("TBD: View to enter new project data here")
                    .font(primary)
                    .foregroundColor(.primaryText)

                Button(action: {
                    viewModel.onLogout()
                }, label: {
                    Text("Close")
                })
                .buttonStyle(ActionButtonStyle())
            }
        }
    }
}
