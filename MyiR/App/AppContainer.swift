//
//  AppContainer.swift
//  MyiR
//
//  Created by Youngmin Cho on 8/29/26.
//

import Foundation

@MainActor
final class AppContainer {
    let loginViewModel: LoginViewModel

    init() {
        let authRepository = InMemoryAuthRepository()

        let signInUseCase = SignInUseCase(
            authRepository: authRepository
        )

        loginViewModel = LoginViewModel(
            signInUseCase: signInUseCase
        )
    }
}
