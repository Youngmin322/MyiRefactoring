//
//  AuthUser.swift
//  MyiR
//
//  Created by Youngmin Cho on 8/27/26.
//

struct AuthUser: Identifiable, Equatable, Sendable {
    struct ID: Hashable, Sendable {
        let value: String
    }
    
    let id: ID
    let displayName: String?
    let email: String?
    let signInProvider: SignInProvider
}
