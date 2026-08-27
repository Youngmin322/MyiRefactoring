//
//  AppDependencyContainer.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/27/26.
//

import Foundation
import SwiftData

@MainActor
final class AppDependencyContainer {
    private let babyProfileRepository: BabyProfileRepository

    init() throws {
        let modelContainer = try ModelContainer(for: BabyProfileModel.self)
        babyProfileRepository = SwiftDataBabyProfileRepository(modelContainer: modelContainer)
    }

    /// 실제 저장소를 쓰지 않는 Preview용.
    init(babyProfileRepository: BabyProfileRepository) {
        self.babyProfileRepository = babyProfileRepository
    }

    func makeRootViewModel() -> RootViewModel {
        RootViewModel(repository: babyProfileRepository)
    }

    func makeBabyRegisterViewModel() -> BabyRegisterViewModel {
        BabyRegisterViewModel(repository: babyProfileRepository)
    }
}
