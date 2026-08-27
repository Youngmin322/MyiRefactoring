//
//  MyiRApp.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/27/26.
//

import SwiftUI

@main
struct MyiRApp: App {
    private let container = AppDependencyContainer()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}
