//
//  InMemoryBabyProfileRepository.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/27/26.
//

import Foundation

/// 영속성 방식이 정해지기 전까지 쓰는 임시 구현.
/// 앱을 종료하면 등록 정보가 사라져 다시 등록 화면부터 시작한다.
actor InMemoryBabyProfileRepository: BabyProfileRepository {
    private var profile: BabyProfile?
    private var continuations: [UUID: AsyncStream<BabyProfile?>.Continuation] = [:]

    nonisolated func stream() -> AsyncStream<BabyProfile?> {
        let (stream, continuation) = AsyncStream<BabyProfile?>.makeStream()
        let id = UUID()

        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeContinuation(id: id) }
        }
        Task { await addContinuation(continuation, id: id) }

        return stream
    }

    func register(_ profile: BabyProfile) async throws {
        self.profile = profile
        for continuation in continuations.values {
            continuation.yield(profile)
        }
    }

    private func addContinuation(
        _ continuation: AsyncStream<BabyProfile?>.Continuation,
        id: UUID
    ) {
        continuations[id] = continuation
        continuation.yield(profile)
    }

    private func removeContinuation(id: UUID) {
        continuations[id] = nil
    }
}
