//
//  ContentViewModel.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 18/03/2024.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {

    @Published var deeplinkGroups: [DeeplinkGroup]?

    @Published var isLoading: Bool = true
    @Published var error: DeeplinkError?

    private var database: DatabaseProtocol
    private var bag: Set<AnyCancellable> = []
    private var databaseListener: AnyCancellable?

    private var user: String
    private var pwd: String

    init(database: DatabaseProtocol) {
        self.database = database
        self.user = "dt"
        self.pwd = "pwd"
    }

    func onAppear() {

        isLoading = true

        databaseListener?.cancel()
        databaseListener = database.deeplinkUpdates(for: user, pwd: pwd)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in

                switch status {
                case .success(let deeplinkGroups):
                    self?.deeplinkGroups = deeplinkGroups ?? []
                    self?.isLoading = false

                case .error(let error):
                    self?.error = error
                    self?.isLoading = false

                default:
                    break
                }
            }
    }
}
