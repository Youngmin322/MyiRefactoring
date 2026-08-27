//
//  BabyProfileModel.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/28/26.
//

import Foundation
import SwiftData

/// SwiftData 저장용 모델.
@Model
final class BabyProfileModel {
    var id: UUID
    var name: String
    var birthDate: Date
    var gender: Gender
    var bloodType: BloodType

    init(
        id: UUID,
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

extension BabyProfileModel {
    convenience init(_ profile: BabyProfile) {
        self.init(
            id: profile.id,
            name: profile.name,
            birthDate: profile.birthDate,
            gender: profile.gender,
            bloodType: profile.bloodType
        )
    }

    var domainValue: BabyProfile {
        BabyProfile(
            id: id,
            name: name,
            birthDate: birthDate,
            gender: gender,
            bloodType: bloodType
        )
    }
}
