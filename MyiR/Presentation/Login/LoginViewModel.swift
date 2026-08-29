//
//  LoginViewModel.swift
//  MyiR
//
//  Created by Youngmin Cho on 8/29/26.
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var session: AuthSession = .signedOut

    private let signInUseCase: SignInUseCase

    init(signInUseCase: SignInUseCase) {
        self.signInUseCase = signInUseCase
    }

    func signIn(
        with provider: SignInProvider
    ) async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            session = try await signInUseCase.execute(
                with: provider
            )
        } catch {
            errorMessage = "로그인에 실패했습니다."
        }
    }
}
