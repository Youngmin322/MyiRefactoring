//
//  BabyRegisterViewModel.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/27/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class BabyRegisterViewModel {
    var name: String = ""
    var birthDate: Date = Date()
    var isTimeSelectionEnabled: Bool = false
    var gender: Gender?
    var bloodType: BloodType?

    private(set) var isSubmitting = false
    private(set) var errorMessage: String?

    private let repository: BabyProfileRepository

    init(repository: BabyProfileRepository) {
        self.repository = repository
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSubmit: Bool {
        !trimmedName.isEmpty && gender != nil && bloodType != nil && !isSubmitting
    }

    func register() {
        Task { await performRegister() }
    }

    private func performRegister() async {
        guard !isSubmitting, !trimmedName.isEmpty,
              let gender, let bloodType
        else { return }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await repository.register(
                BabyProfile(
                    name: trimmedName,
                    birthDate: birthDate,
                    gender: gender,
                    bloodType: bloodType
                )
            )
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
