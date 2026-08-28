//
//  BabyGrowthStage.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/28/26.
//

import Foundation

enum BabyGrowthStage: Sendable {
    case newborn
    case infant
    case toddler
    case child
}

extension BabyProfile {
    /// 태어난 날을 1일로 센 일수.
    func daysOld(on date: Date = Date(), calendar: Calendar = .current) -> Int {
        let from = calendar.startOfDay(for: birthDate)
        let to = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: from, to: to).day ?? 0
        return days + 1
    }

    func growthStage(on date: Date = Date(), calendar: Calendar = .current) -> BabyGrowthStage {
        let months = calendar.dateComponents([.month], from: birthDate, to: date).month ?? 0

        if months == 0, daysOld(on: date, calendar: calendar) <= 30 { return .newborn }
        if months < 12 { return .infant }
        if months < 36 { return .toddler }
        return .child
    }
}
