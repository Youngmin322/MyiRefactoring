//
//  BabyRegisterViewModelTests.swift
//  MyiRTests
//
//  Created by Tom Bum Su Choi on 8/28/26.
//

import Foundation
import Testing
@testable import MyiR

@MainActor
struct BabyRegisterViewModelTests {
    private func makeViewModel(
        repository: BabyProfileRepository = StubBabyProfileRepository(values: [])
    ) -> BabyRegisterViewModel {
        BabyRegisterViewModel(repository: repository)
    }

    @Test func 초기에는_성별과_혈액형이_선택되어_있지_않다() {
        // Given: 갓 만들어진 뷰모델
        let viewModel = makeViewModel()

        // Then: 사용자가 고르기 전이므로 비어 있다
        #expect(viewModel.gender == nil)
        #expect(viewModel.bloodType == nil)
    }

    @Test func 이름이_공백뿐이면_등록할_수_없다() {
        // Given: 이름이 공백뿐인 입력
        let viewModel = makeViewModel()

        // When: 공백 이름과 나머지 값을 채운다
        viewModel.name = "   "
        viewModel.gender = .female
        viewModel.bloodType = .ab

        // Then: 등록 버튼이 활성화되지 않는다
        #expect(viewModel.canSubmit == false)
    }

    @Test func 성별을_고르지_않으면_등록할_수_없다() {
        // Given: 새 뷰모델
        let viewModel = makeViewModel()

        // When: 성별만 비워 둔다
        viewModel.name = "짱아"
        viewModel.bloodType = .ab

        // Then: 등록 버튼이 활성화되지 않는다
        #expect(viewModel.canSubmit == false)
    }

    @Test func 혈액형을_고르지_않으면_등록할_수_없다() {
        // Given: 새 뷰모델
        let viewModel = makeViewModel()

        // When: 혈액형만 비워 둔다
        viewModel.name = "짱아"
        viewModel.gender = .female

        // Then: 등록 버튼이 활성화되지 않는다
        #expect(viewModel.canSubmit == false)
    }

    @Test func 이름_성별_혈액형을_모두_채우면_등록할_수_있다() {
        // Given: 새 뷰모델
        let viewModel = makeViewModel()

        // When: 필수값을 모두 채운다
        viewModel.name = "짱아"
        viewModel.gender = .female
        viewModel.bloodType = .ab

        // Then: 등록 버튼이 활성화된다
        #expect(viewModel.canSubmit)
    }

    @Test func 등록하면_이름의_앞뒤_공백이_제거된다() async throws {
        // Given: 이름 앞뒤에 공백이 있는 입력
        let repository = RecordingBabyProfileRepository()
        let viewModel = makeViewModel(repository: repository)
        viewModel.name = "  짱아  "
        viewModel.gender = .female
        viewModel.bloodType = .ab

        // When: 등록한다
        viewModel.register()
        try await Task.sleep(for: .milliseconds(100))

        // Then: 공백이 제거된 이름으로 저장된다
        let registered = await repository.registered
        #expect(registered.count == 1)
        #expect(registered.first?.name == "짱아")
    }

    @Test func 필수값이_없으면_등록되지_않는다() async throws {
        // Given: 이름만 채우고 성별·혈액형은 비운 입력
        let repository = RecordingBabyProfileRepository()
        let viewModel = makeViewModel(repository: repository)
        viewModel.name = "짱아"

        // When: 등록을 시도한다
        viewModel.register()
        try await Task.sleep(for: .milliseconds(100))

        // Then: 저장소에 아무것도 기록되지 않는다
        let registered = await repository.registered
        #expect(registered.isEmpty)
    }
}
