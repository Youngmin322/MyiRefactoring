//
//  InMemoryBabyProfileRepositoryTests.swift
//  MyiRTests
//
//  Created by Tom Bum Su Choi on 8/28/26.
//

import Foundation
import Testing
@testable import MyiR

struct InMemoryBabyProfileRepositoryTests {
    private func makeProfile(name: String = "짱아") -> BabyProfile {
        BabyProfile(
            name: name,
            birthDate: Date(timeIntervalSince1970: 0),
            gender: .female,
            bloodType: .ab
        )
    }

    @Test func 구독하면_현재_값을_즉시_방출한다() async {
        // Given: 아무것도 등록되지 않은 저장소
        let repository = InMemoryBabyProfileRepository()
        var iterator = repository.stream().makeAsyncIterator()

        // When: 스트림을 구독한다
        let first = await iterator.next()

        // Then: 기다리지 않고 현재 값(nil)을 받는다
        #expect(first == .some(nil))
    }

    @Test func 등록하면_구독자에게_전파된다() async throws {
        // Given: 이미 구독 중인 저장소
        let repository = InMemoryBabyProfileRepository()
        var iterator = repository.stream().makeAsyncIterator()
        _ = await iterator.next()

        // When: 아기를 등록한다
        try await repository.register(makeProfile())

        // Then: 구독자가 등록된 값을 받는다
        let next = await iterator.next()
        #expect(next??.name == "짱아")
    }

    @Test func 구독자가_여럿이면_모두_전파받는다() async throws {
        // Given: 두 곳에서 구독 중인 저장소
        let repository = InMemoryBabyProfileRepository()
        var first = repository.stream().makeAsyncIterator()
        var second = repository.stream().makeAsyncIterator()
        _ = await first.next()
        _ = await second.next()

        // When: 아기를 등록한다
        try await repository.register(makeProfile(name: "흰둥이"))

        // Then: 두 구독자 모두 등록된 값을 받는다
        let firstValue = await first.next()
        let secondValue = await second.next()
        #expect(firstValue??.name == "흰둥이")
        #expect(secondValue??.name == "흰둥이")
    }

    @Test func 나중에_구독해도_이미_등록된_값을_받는다() async throws {
        // Given: 아기가 이미 등록된 저장소
        let repository = InMemoryBabyProfileRepository()
        try await repository.register(makeProfile())

        // When: 등록 이후에 구독한다
        var iterator = repository.stream().makeAsyncIterator()

        // Then: 놓치지 않고 현재 값을 받는다
        let first = await iterator.next()
        #expect(first??.name == "짱아")
    }
}
