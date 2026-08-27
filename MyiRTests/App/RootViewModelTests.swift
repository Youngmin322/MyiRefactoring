//
//  RootViewModelTests.swift
//  MyiRTests
//
//  Created by Tom Bum Su Choi on 8/28/26.
//

import Foundation
import Testing
@testable import MyiR

@MainActor
struct RootViewModelTests {
    private func makeProfile() -> BabyProfile {
        BabyProfile(
            name: "짱아",
            birthDate: Date(timeIntervalSince1970: 0),
            gender: .female,
            bloodType: .ab
        )
    }

    @Test func 관찰_전에는_로딩_상태다() {
        // Given: 아직 관찰을 시작하지 않은 뷰모델
        let viewModel = RootViewModel(repository: StubBabyProfileRepository(values: []))

        // Then: 로딩 상태로 시작한다
        #expect(viewModel.state == .loading)
    }

    @Test func 등록된_아기가_없으면_등록이_필요한_상태가_된다() async {
        // Given: 등록된 아기가 없는 저장소
        let viewModel = RootViewModel(repository: StubBabyProfileRepository(values: [nil]))

        // When: 저장소를 관찰한다
        await viewModel.observe()

        // Then: 등록 화면이 필요한 상태가 된다
        #expect(viewModel.state == .needsRegistration)
    }

    @Test func 등록된_아기가_있으면_등록된_상태가_된다() async {
        // Given: 아기가 이미 등록된 저장소
        let viewModel = RootViewModel(
            repository: StubBabyProfileRepository(values: [makeProfile()])
        )

        // When: 저장소를 관찰한다
        await viewModel.observe()

        // Then: 등록된 상태가 된다
        #expect(viewModel.state == .registered)
    }

    @Test func 등록되면_등록이_필요한_상태에서_등록된_상태로_바뀐다() async {
        // Given: 비어 있다가 아기가 등록되는 저장소
        let viewModel = RootViewModel(
            repository: StubBabyProfileRepository(values: [nil, makeProfile()])
        )

        // When: 저장소를 관찰한다
        await viewModel.observe()

        // Then: 마지막 값을 따라 등록된 상태가 된다
        #expect(viewModel.state == .registered)
    }
}
