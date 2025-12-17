//
//  DeeplinkContentModel.swift
//  Deeplinks
//
//  Created by Geza Dezso on 2025. 11. 12..
//

import Combine
import Foundation

enum DeeplinkContentModelState {
    case fetching
    case ready([DeeplinkGroup]?)
    case error(DeeplinkError)
}

enum DeeplinkItemType {
    case group(title: String)
    case deeplink(groupTitle: String, deeplink: Deeplink)
}

class DeeplinkContentModel {

    private var database: DatabaseProtocol
    private var bag: Set<AnyCancellable> = []
    private var databaseListener: AnyCancellable?

    @Published public var state: DeeplinkContentModelState = .fetching
    var lastCreatedItem = PassthroughSubject<DeeplinkItemType?, Never>()
    var updateError = PassthroughSubject<DeeplinkError?, Never>()

    init(database: DatabaseProtocol) {
        self.database = database
    }

    var deeplinkGroups: [DeeplinkGroup]? {
        switch state {
        case .ready(let groups):
            return groups
        default:
            return nil
        }
    }

    func updatesPublisher(user: String, pwd: String = "") -> AnyPublisher<DeeplinkContentModelState, Never> {
        setupListener(user: user, pwd: pwd)

        return $state
            .eraseToAnyPublisher()
    }

    private func setupListener(user: String, pwd: String) {
        databaseListener?.cancel()
        databaseListener = database.updatesPublisher(user: user, pwd: pwd)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }

                switch status {
                case .success(let deeplinkGroups):
                    state = .ready(deeplinkGroups)

                case .error(let error):
                    state = .error(error)

                default:
                    break
                }
            }
    }
}

// MARK: Update methods

extension DeeplinkContentModel {

    func append(group: DeeplinkGroup) {
        guard var deeplinkGroups else { return }

        deeplinkGroups.append(group)

        Task {
            if await update(content: deeplinkGroups) {
                lastCreatedItem.send(.group(title: group.title))
            } else {
                updateError.send(.updateFailed)
            }
        }
    }

    func append(_ deeplink: Deeplink, to group: DeeplinkGroup) {
        guard var deeplinkGroups else { return }

        if let groupIndex = deeplinkGroups.firstIndex(where: { group == $0 }) {
            var group = deeplinkGroups[groupIndex]
            var deeplinks = group.deeplinks ?? []
            deeplinks.append(deeplink)
            group.deeplinks = deeplinks
            deeplinkGroups[groupIndex] = group

            Task {
                if await update(content: deeplinkGroups) {
                    lastCreatedItem.send(.deeplink(groupTitle: group.title, deeplink: deeplink))
                } else {
                    updateError.send(.updateFailed)
                }
            }
        } else {
            updateError.send(.updateSectionNotFound)
        }
    }

    func update(_ deeplink: Deeplink, with newDeeplink: Deeplink, in group: DeeplinkGroup) {
        guard var deeplinkGroups else { return }

        if let groupIndex = deeplinkGroups.firstIndex(where: { group == $0 }) {
            var group = deeplinkGroups[groupIndex]
            if let index = group.deeplinks?.firstIndex(where: { deeplink == $0 }) {
                group.deeplinks?[index] = newDeeplink
                deeplinkGroups[groupIndex] = group
                Task {
                    if await update(content: deeplinkGroups) {

                    } else {
                        updateError.send(.updateFailed)
                    }
                }
            } else {
                // deeplink entry not found, might have been deleted, append to group
                append(newDeeplink, to: group)
            }
        } else {
            updateError.send(.updateSectionNotFound)
        }
    }

    private func update(content: [DeeplinkGroup]) async -> Bool {
        (try? await database.update(content: content)) != nil
    }
}

// MARK: Check new/modified items validity

extension DeeplinkContentModel {

    func validate(_ groupTitle: String) -> DeeplinkEditError? {
        if isDuplicate(groupTitle) {
            return .duplicate(isSection: true)
        }
        return nil
    }

    func validate(_ deeplink: Deeplink, oldValue: Deeplink? = nil, in group: DeeplinkGroup) -> DeeplinkEditError? {
        if isDuplicate(deeplink, oldValue: oldValue, in: group) {
            return .duplicate(isSection: false)
        }
        if URL(deeplink.url) == nil {
            return .invalidUrl
        }
        return nil
    }

    private func isDuplicate(_ groupTitle: String) -> Bool {
        deeplinkGroups?.first(where: { $0.title == groupTitle }) != nil
    }

    private func isDuplicate(_ deeplink: Deeplink, oldValue: Deeplink? = nil, in group: DeeplinkGroup) -> Bool {
        group.deeplinks?.filter({ $0 != oldValue }).contains(deeplink) == true
    }
}
