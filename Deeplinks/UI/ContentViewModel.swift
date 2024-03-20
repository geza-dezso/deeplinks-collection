//
//  ContentViewModel.swift
//  Deeplinks Collection
//
//  Created by Geza Dezso on 18/03/2024.
//

import Foundation

class ContentViewModel: ObservableObject {

    var deeplinks: [String]?

    @Published var isLoading: Bool = true
    @Published var error: DeeplinkError?

    private var database: DatabaseProtocol

    init(database: DatabaseProtocol) {
        self.database = database
    }

    func onAppear() {
        isLoading = true
        database.deeplinks(for: "user1", pwd: "pwd1") { [weak self] deeplinks in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.deeplinks = deeplinks
                self.error = nil
                self.isLoading = false
            }

        } failure: { [weak self] error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.deeplinks = nil
                self.error = error
                self.isLoading = false
            }
        }
    }
}
