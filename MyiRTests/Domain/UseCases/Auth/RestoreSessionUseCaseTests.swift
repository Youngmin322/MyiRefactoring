//
//  RestoreSessionUseCaseTests.swift
//  MyiRTests
//
//  Created by Youngmin Cho on 8/28/26.
//

import Testing
@testable import MyiR

struct RestoreSessionUseCaseTests {
    @Test
    func 저장소의_인증_세션을_반환한다() async {
        let expectedSession = AuthSession.signedIn(
            AuthUser(
                id: .init(value: "user-test-001"),
                displayName: "테스트 사용자",
                email: "parent@example.invalid",
                signInProvider: .apple
            )
        )
        let repository = AuthRepositorySpy(
            restoredSession: expectedSession
        )
        let sut = RestoreSessionUseCase(
            authRepository: repository
        )

        let session = await sut.execute()
        let callCount = await repository.restoreSessionCallCount

        #expect(session == expectedSession)
        #expect(callCount == 1)
    }
}
