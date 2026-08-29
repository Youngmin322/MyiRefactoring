//
//  LoginView.swift
//  MyiR
//
//  Created by Youngmin Cho on 8/28/26.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack {
            Spacer()

            Text("My i")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundStyle(Color("LaunchScreenTextColor"))
                .padding(.top, 100)

            Text("쉽고 편한 육아 기록 앱")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color("LaunchScreenTextColor"))
                .padding(.bottom, 30)

            Image("launchScreenImage")
                .resizable()
                .scaledToFit()
                .frame(width: 431, height: 431)
                .offset(y: -1)

            Button(action: {
                Task {
                    await viewModel.signIn(with: .google)
                }
            }) {
                HStack(spacing: 8) {
                    Image("google-logo-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)

                    Text("Sign in with Google")
                        .font(.system(size: 18.5, weight: .semibold))
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
            }
            .disabled(viewModel.isLoading)
            .buttonStyle(LoginButtonStyle())
            .padding(.horizontal, 50)
            .offset(y: -20)

            Button(action: {
                print("애플 로그인")
                Task {
                    await viewModel.signIn(with: .apple)
                }
            }) {
                Label("Sign in with Apple", systemImage: "apple.logo")
            }
            .buttonStyle(LoginButtonStyle())
            .disabled(viewModel.isLoading)
            .padding(.horizontal, 50)
            .padding(.bottom, 150)

            Spacer()
        }
        .background(Color("LaunchScreenColor"))
        .ignoresSafeArea()
    }
}

private struct LoginButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18.5, weight: .semibold))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.black, lineWidth: 0.8)
            }
    }
}

#Preview {
    LoginView(
        viewModel: LoginViewModel(
            signInUseCase: SignInUseCase(
                authRepository: InMemoryAuthRepository()
            )
        )
    )
}
