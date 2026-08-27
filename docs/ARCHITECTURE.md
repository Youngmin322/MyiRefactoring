# 아키텍처 결정 문서

## Status

이 문서는 앞으로의 코드베이스를 어떤 구조로 가져갈지 정하기 위해 작성한다.

## Decision

**Clean Architecture(Presentation / Domain / Data)**를 **Feature-first** 폴더 구조 위에 얹는다. 즉 최상위는 Feature 단위로 나누고, 각 Feature 내부를 계층으로 나눈다.

## 폴더 구조

```
MyiR/
├── MyiRApp.swift
├── Assets.xcassets/
├── App/
│   ├── MyiRApp.swift                 @main, 컨테이너 생성 후 RootView에 전달
│   ├── AppDependencyContainer.swift  DI 컴포지션 루트
│   └── RootView.swift                ContentView를 대체
├── Core/                             프레임워크 비종속, 앱 도메인 지식 없음
│   ├── DesignSystem/
│   │   ├── Colors/         (sharkPrimaryColor, boyColor, girlColor 등 래핑)
│   │   ├── Typography/     (BMJUA 폰트 래핑)
│   │   └── Components/     공용 SwiftUI 컴포넌트
│   ├── Extensions/
│   └── Persistence/
├── Shared/                           2개 이상 Feature가 공유하지만 화면은 없는 개념
│   └── BabyStatus/
│       ├── Domain/     (BabyProfile, BabyGrowthStage, BabyGrowthStageCalculator, Repository 프로토콜)
│       ├── Data/        (RepositoryImpl)
│       └── Presentation/ (SharkStatusIcon 매핑)
└── Features/
    ├── Home/
    │   ├── Presentation/
    │   │   ├── Views/       (HomeView, RecordEntryGridView, RecordEntryButton)
    │   │   └── ViewModels/  (HomeViewModel)
    │   ├── Domain/
    │   │   ├── Entities/     (RecordEntry)
    │   │   ├── UseCases/     (FetchTodayRecordsUseCase)
    │   │   └── Repositories/ (RecordRepository 프로토콜)
    │   └── Data/
    │       ├── DataSources/  (RecordLocalDataSource)
    │       └── Repositories/ (RecordRepositoryImpl)
    ├── Analysis/    # Home과 동일 3계층 패턴
    ├── Setting/     # 동일 패턴, UseCase는 대부분 생략(아래 DI 방식 참고)
    └── Auth/
        ├── Presentation/ (LoginView, LoginViewModel)
        ├── Domain/       (AuthenticatedUser, SignInWithGoogleUseCase, AuthRepository 프로토콜)
        └── Data/         (AuthRepositoryImpl — 지금은 스텁, 나중에 GoogleSignIn으로 교체)
```

### 네이밍 규칙

| 위치                    | 패턴                                                    |
|-------------------------|---------------------------------------------------------|
| Presentation/Views      | `<Name>View.swift`                                      |
| Presentation/ViewModels | `<Name>ViewModel.swift` (`@Observable`, MainActor 기본) |
| Domain/Entities         | `<Noun>.swift`                                          |
| Domain/UseCases         | `<Verb><Noun>UseCase.swift`                             |
| Domain/Repositories     | `<Noun>Repository.swift` (프로토콜)                     |
| Data/Repositories       | `<Noun>RepositoryImpl.swift`                            |
| Data/DataSources        | `<Noun>LocalDataSource.swift`                           |

`DTOs/`는 미리 만들지 않는다. 영속성 모델 구조가 Domain Entity와 실제로 달라지는 시점에만 추가한다(단순 1:1 매핑이면 `RepositoryImpl` 안의 private 확장으로 충분).

### 교차 관심사는 어디로 가는가

- **RecordCategory(기록 유형별 색상·아이콘 매핑)** → `Core/DesignSystem/RecordTheme.swift`. 순수 룩업 테이블(비즈니스 규칙 아님)이라 Core가 맞다. `RecordColors`의 `food`와 `HomeIcons`의 `colorMeal`처럼 이미 존재하는 네이밍 불일치를 여기 한 곳에서 흡수한다. `memo`처럼 전용 색이 없는 항목은 기본값(fallback)을 명시적으로 정의한다.
- **상어 성장 단계 계산** → `Shared/BabyStatus/`. `BabyProfile.birthDate` → `BabyGrowthStage`로 변환하는 실제 도메인 로직이며 Home과 Analysis 둘 다 사용한다. Core에 넣지 않는 이유는 "Core는 비즈니스 로직을 갖지 않는다"는 규칙을 지키기 위함이다. 어느 한 Feature 안에 넣으면 다른 Feature가 그 Feature 내부를 참조해야 하므로 Shared로 분리한다.

> `BabyProfile`을 `Shared/BabyStatus/`에 둘지, Setting 내부에 두고 Home/Analysis가 참조하게 할지는 아직 팀 확정 사항이 아니다. Open Questions 참고.

## 의존성 규칙

- **Domain**: `Foundation`만 import. `SwiftUI`, `Combine`, `SwiftData`, `UIKit`, 서드파티 SDK(GoogleSignIn 포함) import 금지. 비동기는 `async/await`만 사용한다 — 프로젝트가 이미 `SWIFT_APPROACHABLE_CONCURRENCY` / `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`로 Swift 6 동시성 모델을 채택했으므로 Combine을 섞지 않는다.
- **Presentation**: `SwiftUI` + Domain만 import. ViewModel은 Domain 프로토콜(UseCase 또는 Repository)만 생성자로 주입받고, `...Impl`이나 DataSource 타입을 직접 알지 못한다.
- **Data**: Domain 프로토콜을 준수하기 위한 import + 영속성/SDK 프레임워크. `SwiftUI` import 금지.
- 하나의 앱 타겟 안에서 폴더로만 나눈 구조이므로 Feature 간 격리는 **컴파일러가 강제하지 않는다.** 코드 리뷰로 지켜야 하는 컨벤션이라는 점을 인지하고 간다.

## DI 방식

서드파티 DI 프레임워크 없이 수동 생성자 주입 + 단일 컴포지션 루트를 쓴다.

```swift
// App/AppDependencyContainer.swift
@MainActor
final class AppDependencyContainer {
    private let babyProfileRepository: BabyProfileRepository
    private let recordLocalDataSource: RecordLocalDataSource

    init() {
        babyProfileRepository = BabyProfileRepositoryImpl()
        recordLocalDataSource = RecordLocalDataSource()
    }

    func makeHomeViewModel() -> HomeViewModel {
        let repository = RecordRepositoryImpl(localDataSource: recordLocalDataSource)
        return HomeViewModel(
            fetchTodayRecordsUseCase: FetchTodayRecordsUseCase(repository: repository),
            babyProfileRepository: babyProfileRepository
        )
    }
}
```

`RootView`는 컨테이너 전체를 `.environment()`로 뿌리지 않고, 화면마다 필요한 `make*ViewModel()` 팩토리만 호출한다. 컨테이너를 통째로 넘기면 아무 화면이나 관계없는 의존성에 접근할 수 있게 되어 계층 분리 의미가 없어진다.

**사소한 동작에는 UseCase를 만들지 않는다.** 예를 들어 Setting의 알림 토글처럼 단순 pass-through 동작은 ViewModel이 Repository 프로토콜을 바로 호출해도 된다. UseCase는 실제로 조합·검증 로직이 있을 때만(`BabyGrowthStageCalculator`, 여러 기록 유형을 합산하는 `FetchTodayRecordsUseCase` 등) 도입한다.

## Consequences

**얻는 것**
- Data 구현체 교체가 쉽다 (Auth의 스텁 → 실제 GoogleSignIn 연동 시 Presentation/Domain은 그대로)
- Feature가 물리적으로 분리돼 있어 2인 팀의 병렬 작업이 쉬움
- `food`/`colorMeal` 같은 네이밍 불일치를 한 곳(RecordTheme)에서 해소
- 테스트 타겟이 생기면 가짜 Repository로 ViewModel/UseCase를 독립적으로 테스트 가능

**드는 비용**
- Setting처럼 작은 Feature에도 계층별 파일이 여러 개 생김 (UseCase 생략 규칙으로 일부 완화)
- 하나의 앱 타겟이라 Feature 경계가 컴파일러가 아닌 리뷰 규율에 의존
- 수동 DI 컨테이너는 Feature가 늘어날수록 관리가 필요
- 지금 앱 규모에 비해 구조가 다소 무거울 수 있음 — 팀이 명시적으로 Clean Architecture를 요청했고, 앞으로 붙을 영속성/인증/분석 백엔드의 리스크를 미리 낮추기 위해 감수하는 트레이드오프로 채택

## Open Questions / Future Considerations

- Home 기록 저장소: SwiftData vs UserDefaults 미정 (`Core/Persistence`, `RecordLocalDataSource` 구현에 영향)
- `BabyProfile`을 `Shared/`에 둘지 Setting 내부에 둘지 팀 확정 필요
- Analysis의 실제 울음 분석 방식(온디바이스 CoreML vs 서버 API) 미정 — `Core/Networking` 신설 여부와 Analysis의 액터 격리 방식에 영향
- Feature 수가 늘어나면 로컬 SPM 패키지로 물리적 분리하는 것을 검토