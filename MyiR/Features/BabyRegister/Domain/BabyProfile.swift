//
//  BabyProfile.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/27/26.
//

import Foundation

struct BabyProfile: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var birthDate: Date
    var gender: Gender
    var bloodType: BloodType

    init(
        id: UUID = UUID(),
        name: String,
        birthDate: Date,
        gender: Gender,
        bloodType: BloodType
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.bloodType = bloodType
    }
}
