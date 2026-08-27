//
//  StubBabyProfileRepository.swift
//  MyiRTests
//
//  Created by Tom Bum Su Choi on 8/28/26.
//

import Foundation
@testable import MyiR

/// 정해진 값을 순서대로 방출하고 끝나는 저장소.
/// 스트림이 끝나므로 `observe()`가 반환되어 테스트가 결정적으로 동작한다.
struct StubBabyProfileRepository: BabyProfileRepository {
    let values: [BabyProfile?]

    func stream() -> AsyncStream<BabyProfile?> {
        AsyncStream { continuation in
            for value in values {
                continuation.yield(value)
            }
            continuation.finish()
        }
    }

    func register(_ profile: BabyProfile) async throws {}
}

/// 등록된 값을 기록하는 저장소.
actor RecordingBabyProfileRepository: BabyProfileRepository {
    private(set) var registered: [BabyProfile] = []

    nonisolated func stream() -> AsyncStream<BabyProfile?> {
        AsyncStream { $0.finish() }
    }

    func register(_ profile: BabyProfile) async throws {
        registered.append(profile)
    }
}
