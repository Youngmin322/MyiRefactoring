//
//  AuthSession.swift
//  MyiR
//
//  Created by Youngmin Cho on 8/28/26.
//

enum AuthSession: Equatable, Sendable {
    case signedOut
    case signedIn(AuthUser)
}
