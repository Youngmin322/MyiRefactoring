//
//  SignInUseCase.swift
//  MyiR
//
//  Created by Youngmin Cho on 8/28/26.
//

struct SignInUseCase: Sendable {
    private let authRepository: any AuthRepository
    
    init(authRepository: any AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute(
        with provider: SignInProvider
    ) async throws -> AuthSession {
        try await authRepository.signIn(with: provider)
    }
}
