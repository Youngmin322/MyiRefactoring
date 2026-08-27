//
//  MyiRApp.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/27/26.
//

import OSLog
import SwiftUI

@main
struct MyiRApp: App {
    private let container: AppDependencyContainer?

    init() {
        do {
            container = try AppDependencyContainer()
        } catch {
            container = nil
            Logger(subsystem: "co.kr.youngmin.MyiR", category: "startup")
                .error("저장소를 열지 못했습니다: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if let container {
                RootView(container: container)
            } else {
                StorageUnavailableView()
            }
        }
    }
}
