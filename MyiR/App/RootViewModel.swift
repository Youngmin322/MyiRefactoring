//
//  RootViewModel.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/27/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class RootViewModel {
    enum State: Equatable {
        case loading
        case needsRegistration
        case registered
    }

    private(set) var state: State = .loading

    private let repository: BabyProfileRepository

    init(repository: BabyProfileRepository) {
        self.repository = repository
    }

    func observe() async {
        for await profile in repository.stream() {
            state = profile == nil ? .needsRegistration : .registered
        }
    }
}
