//
//  StorageUnavailableView.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/28/26.
//

import SwiftUI

/// 저장소를 열지 못해 앱을 시작할 수 없을 때 보여주는 화면.
struct StorageUnavailableView: View {
    var body: some View {
        ContentUnavailableView {
            Label("저장소를 열 수 없어요", systemImage: "externaldrive.badge.xmark")
        } description: {
            Text("앱을 다시 실행해 주세요. 문제가 계속되면 앱을 지웠다가 다시 설치해 주세요.")
        }
    }
}

#Preview {
    StorageUnavailableView()
}
