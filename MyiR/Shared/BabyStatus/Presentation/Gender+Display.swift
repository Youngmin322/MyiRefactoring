//
//  Gender+Display.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/27/26.
//

import SwiftUI

extension Gender {
    /// Text에 그대로 넘겨 String Catalog로 번역되도록 LocalizedStringKey로 둔다.
    var displayName: LocalizedStringKey {
        switch self {
        case .male: "남자"
        case .female: "여자"
        }
    }
}
