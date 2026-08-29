//
//  RestoreSessionUseCase.swift
//  MyiR
//
//  Created by Youngmin Cho on 8/28/26.
//

struct RestoreSessionUseCase: Sendable {
    private let authRepository: any AuthRepository

    init(authRepository: any AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() async -> AuthSession {
        await authRepository.restoreSession()
    }
}
