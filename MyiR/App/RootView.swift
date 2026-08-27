//
//  RootView.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/27/26.
//

import SwiftUI

struct RootView: View {
    let container: AppDependencyContainer

    var body: some View {
        Text("MyiR")
    }
}

#Preview {
    RootView(container: AppDependencyContainer())
}
