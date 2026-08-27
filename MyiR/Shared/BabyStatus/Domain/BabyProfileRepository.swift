//
//  BabyProfileRepository.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/27/26.
//

import Foundation

protocol BabyProfileRepository: Sendable {
    /// 구독 즉시 현재 값을 방출하고, 이후 변경될 때마다 방출한다.
    /// 등록된 아기가 없으면 nil.
    func stream() -> AsyncStream<BabyProfile?>
    func register(_ profile: BabyProfile) async throws
}
