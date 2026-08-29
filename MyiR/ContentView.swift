//
//  ContentView.swift
//  MyiR
//
//  Created by Youngmin Cho on 8/27/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var loginViewModel: LoginViewModel

    init(loginViewModel: LoginViewModel) {
        _loginViewModel = StateObject(
            wrappedValue: loginViewModel
        )
    }

    var body: some View {
        LoginView(viewModel: loginViewModel)
    }
}
