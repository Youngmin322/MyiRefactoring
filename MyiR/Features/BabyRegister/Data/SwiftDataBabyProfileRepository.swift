//
//  SwiftDataBabyProfileRepository.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/28/26.
//

import Foundation
import SwiftData

@ModelActor
actor SwiftDataBabyProfileRepository: BabyProfileRepository {
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
        try modelContext.delete(model: BabyProfileModel.self)
        modelContext.insert(BabyProfileModel(profile))
        try modelContext.save()

        for continuation in continuations.values {
            continuation.yield(profile)
        }
    }

    private func currentProfile() -> BabyProfile? {
        let descriptor = FetchDescriptor<BabyProfileModel>()
        return try? modelContext.fetch(descriptor).first.map(\.domainValue)
    }

    private func addContinuation(
        _ continuation: AsyncStream<BabyProfile?>.Continuation,
        id: UUID
    ) {
        continuations[id] = continuation
        continuation.yield(currentProfile())
    }

    private func removeContinuation(id: UUID) {
        continuations[id] = nil
    }
}
