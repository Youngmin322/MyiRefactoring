//
//  InMemoryAuthRepository.swift
//  MyiR
//
//  Created by Youngmin Cho on 8/29/26.
//

actor InMemoryAuthRepository: AuthRepository {
    private var session: AuthSession = .signedOut

    func restoreSession() async -> AuthSession {
        session
    }

    func signIn(
        with provider: SignInProvider
    ) async throws -> AuthSession {
        let user = AuthUser(
            id: .init(value: "demo-user"),
            displayName: "테스트 보호자",
            email: "parent@example.com",
            signInProvider: provider
        )

        let newSession = AuthSession.signedIn(user)
        session = newSession

        return newSession
    }

    func signOut() async throws {
        session = .signedOut
    }
}
