//
//  AuthRepositorySpy.swift
//  MyiRTests
//
//  Created by Youngmin Cho on 8/28/26.
//

@testable import MyiR

actor AuthRepositorySpy: AuthRepository {
    enum TestError: Error {
        case unexpectedCall
    }

    private let restoredSession: AuthSession
    private(set) var restoreSessionCallCount = 0

    init(restoredSession: AuthSession) {
        self.restoredSession = restoredSession
    }

    func restoreSession() async -> AuthSession {
        restoreSessionCallCount += 1
        return restoredSession
    }

    func signIn(
        with provider: SignInProvider
    ) async throws -> AuthSession {
        throw TestError.unexpectedCall
    }

    func signOut() async throws {
        throw TestError.unexpectedCall
    }
}
