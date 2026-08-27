//
//  BabyRegisterView.swift
//  MyiR
//
//  Created by Tom Bum Su Choi on 8/27/26.
//

import SwiftUI

struct BabyRegisterView: View {
    @State private var viewModel: BabyRegisterViewModel

    init(viewModel: BabyRegisterViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("아기 정보") {
                    TextField("이름", text: $viewModel.name)

                    Toggle("태어난 시각까지 입력", isOn: $viewModel.isTimeSelectionEnabled)

                    DatePicker(
                        "생년월일",
                        selection: $viewModel.birthDate,
                        in: ...Date(),
                        displayedComponents: viewModel.isTimeSelectionEnabled
                            ? [.date, .hourAndMinute]
                            : [.date]
                    )

                    Picker("성별", selection: $viewModel.gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.displayName).tag(Optional(gender))
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("혈액형", selection: $viewModel.bloodType) {
                        ForEach(BloodType.allCases, id: \.self) { bloodType in
                            Text(bloodType.rawValue).tag(Optional(bloodType))
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button("등록하기") {
                        viewModel.register()
                    }
                    .disabled(!viewModel.canSubmit)
                }
            }
            .navigationTitle("아기 등록")
        }
    }
}

#Preview {
    BabyRegisterView(
        viewModel: BabyRegisterViewModel(repository: InMemoryBabyProfileRepository())
    )
}
