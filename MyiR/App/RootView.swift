//
//  RootView.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/27/26.
//

import SwiftUI

struct RootView: View {
    private let container: AppDependencyContainer
    @State private var viewModel: RootViewModel

    init(container: AppDependencyContainer) {
        self.container = container
        _viewModel = State(initialValue: container.makeRootViewModel())
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()

            case .needsRegistration:
                BabyRegisterView(viewModel: container.makeBabyRegisterViewModel())

            case .registered:
                HomeView()
            }
        }
        .task { await viewModel.observe() }
    }
}

#Preview {
    RootView(
        container: AppDependencyContainer(
            babyProfileRepository: InMemoryBabyProfileRepository()
        )
    )
}
