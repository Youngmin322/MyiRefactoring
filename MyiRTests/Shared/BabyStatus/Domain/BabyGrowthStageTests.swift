//
//  BabyGrowthStageTests.swift
//  MyiRTests
//
//  Created by Tom Bum Su Choi on 8/28/26.
//

import Foundation
import Testing
@testable import MyiR

struct BabyGrowthStageTests {
    private let calendar = Calendar(identifier: .gregorian)
    private let today = Date(timeIntervalSince1970: 1_800_000_000)

    private func makeProfile(bornDaysAgo: Int) -> BabyProfile {
        let birthDate = calendar.date(byAdding: .day, value: -bornDaysAgo, to: today)!
        return BabyProfile(name: "짱아", birthDate: birthDate, gender: .female, bloodType: .ab)
    }

    private func makeProfile(bornMonthsAgo: Int) -> BabyProfile {
        let birthDate = calendar.date(byAdding: .month, value: -bornMonthsAgo, to: today)!
        return BabyProfile(name: "짱아", birthDate: birthDate, gender: .female, bloodType: .ab)
    }

    // MARK: - 일수

    @Test func 태어난_날은_1일이다() {
        // Given: 오늘 태어난 아기
        let profile = makeProfile(bornDaysAgo: 0)

        // Then: 1일로 센다
        #expect(profile.daysOld(on: today, calendar: calendar) == 1)
    }

    @Test func 하루_지나면_2일이다() {
        // Given: 어제 태어난 아기
        let profile = makeProfile(bornDaysAgo: 1)

        // Then: 2일로 센다
        #expect(profile.daysOld(on: today, calendar: calendar) == 2)
    }

    // MARK: - 발달 단계

    @Test func 태어난_직후는_신생아기다() {
        // Given: 오늘 태어난 아기
        let profile = makeProfile(bornDaysAgo: 0)

        // Then: 신생아기
        #expect(profile.growthStage(on: today, calendar: calendar) == .newborn)
    }

    @Test func 생후_30일까지는_신생아기다() {
        // Given: 29일 전에 태어난 아기 (30일째)
        let profile = makeProfile(bornDaysAgo: 29)

        // Then: 아직 신생아기
        #expect(profile.growthStage(on: today, calendar: calendar) == .newborn)
    }

    @Test func 생후_31일부터는_영아기다() {
        // Given: 30일 전에 태어난 아기 (31일째)
        let profile = makeProfile(bornDaysAgo: 30)

        // Then: 영아기로 넘어간다
        #expect(profile.growthStage(on: today, calendar: calendar) == .infant)
    }

    @Test func 돌_전까지는_영아기다() {
        // Given: 11개월 된 아기
        let profile = makeProfile(bornMonthsAgo: 11)

        // Then: 영아기
        #expect(profile.growthStage(on: today, calendar: calendar) == .infant)
    }

    @Test func 돌부터는_유아기다() {
        // Given: 12개월 된 아기
        let profile = makeProfile(bornMonthsAgo: 12)

        // Then: 유아기로 넘어간다
        #expect(profile.growthStage(on: today, calendar: calendar) == .toddler)
    }

    @Test func 세돌_전까지는_유아기다() {
        // Given: 35개월 된 아기
        let profile = makeProfile(bornMonthsAgo: 35)

        // Then: 유아기
        #expect(profile.growthStage(on: today, calendar: calendar) == .toddler)
    }

    @Test func 세돌부터는_아동기다() {
        // Given: 36개월 된 아기
        let profile = makeProfile(bornMonthsAgo: 36)

        // Then: 아동기로 넘어간다
        #expect(profile.growthStage(on: today, calendar: calendar) == .child)
    }
}
