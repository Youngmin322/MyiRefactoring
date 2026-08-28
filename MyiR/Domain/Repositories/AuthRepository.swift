//
//  AuthRepository.swift
//  MyiR
//
//  Created by Youngmin Cho on 8/28/26.
//

protocol AuthRepository: Sendable {
    func restoreSession() async -> AuthSession

    func signIn(
        with provider: SignInProvider
    ) async throws -> AuthSession

    func signOut() async throws
}
