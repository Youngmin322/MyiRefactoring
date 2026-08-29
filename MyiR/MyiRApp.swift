//
//  MyiRApp.swift
//  MyiR
//
//  Created by Youngmin Cho on 8/27/26.
//

import SwiftUI

@main
@MainActor
struct MyiRApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            ContentView(
                loginViewModel: container.loginViewModel
            )
        }
    }
}
