# 아키텍처 결정 문서

## Status

이 문서는 앞으로의 코드베이스를 어떤 구조로 가져갈지 정하기 위해 작성한다.
아기 등록 기능을 구현하며 실제로 검증된 내용을 반영해 갱신했다.

## Decision

**Clean Architecture(Presentation / Domain / Data)**를 **Feature-first** 폴더 구조 위에 얹는다. 즉 최상위는 Feature 단위로 나누고, 각 Feature 내부를 계층으로 나눈다.

## 폴더 구조

`*` 표시는 폴더만 있고 아직 구현이 없는 곳이다.

```
MyiR/
├── App/                              앱 조립과 진입점
│   ├── MyiRApp.swift                 @main, 컨테이너 생성 실패 시 안내 화면 분기
│   ├── AppDependencyContainer.swift  DI 컴포지션 루트
│   ├── RootView.swift                등록 여부에 따라 화면 분기
│   ├── RootViewModel.swift           저장소 스트림을 구독해 분기 상태 결정
│   └── StorageUnavailableView.swift  저장소를 열지 못했을 때의 안내 화면
├── Assets.xcassets/
├── Localizable.xcstrings             String Catalog (ko/en/ja/zh-Hans)
├── Core/ *                           프레임워크 비종속, 앱 도메인 지식 없음
│   ├── DesignSystem/{Colors,Typography,Components}/ *
│   ├── Extensions/ *
│   └── Persistence/ *
├── Shared/ *                         2개 이상 Feature가 실제로 공유하게 되면 여기로 옮긴다
│   └── BabyStatus/{Domain,Data,Presentation}/ *
└── Features/
    ├── BabyRegister/                 아기 등록 (구현 완료)
    │   ├── Domain/
    │   │   ├── BabyProfile.swift
    │   │   ├── Gender.swift
    │   │   ├── BloodType.swift
    │   │   └── BabyProfileRepository.swift   (프로토콜)
    │   ├── Data/
    │   │   ├── BabyProfileModel.swift             SwiftData 저장 모델 + 도메인 매핑
    │   │   ├── SwiftDataBabyProfileRepository.swift
    │   │   └── InMemoryBabyProfileRepository.swift 테스트·Preview용
    │   └── Presentation/
    │       ├── Gender+Display.swift               표시 문구
    │       ├── Views/BabyRegisterView.swift
    │       └── ViewModels/BabyRegisterViewModel.swift
    ├── Home/
    │   └── Presentation/Views/HomeView.swift      분기 확인용 플레이스홀더
    ├── Analysis/ *
    ├── Setting/ *
    └── Auth/ *
```

Feature 규모가 작을 때는 `Domain/Entities/`처럼 한 단계 더 파지 않는다. `BabyRegister/Domain/`처럼 평평하게 두고, 파일이 늘어 구분이 필요해지면 그때 나눈다.

### 테스트 구조

`MyiRTests/`는 소스 구조를 그대로 따라간다. 어느 계층을 검증하는 테스트인지 경로만 봐도 드러나게 한다.

```
MyiRTests/
├── App/RootViewModelTests.swift
├── Features/BabyRegister/
│   ├── Data/InMemoryBabyProfileRepositoryTests.swift
│   └── Presentation/ViewModels/BabyRegisterViewModelTests.swift
└── Support/StubBabyProfileRepository.swift   여러 곳에서 쓰는 테스트 대역
```

테스트 본문은 `// Given` / `// When` / `// Then` 주석으로 구분한다.

### 네이밍 규칙

| 위치 | 패턴 |
|------|------|
| Presentation/Views | `<Name>View.swift` |
| Presentation/ViewModels | `<Name>ViewModel.swift` (`@Observable`, MainActor 기본) |
| Presentation (표시 문구·색상 매핑) | `<Type>+Display.swift` |
| Domain (엔티티) | `<Noun>.swift` |
| Domain (유스케이스) | `<Verb><Noun>UseCase.swift` |
| Domain (저장소 프로토콜) | `<Noun>Repository.swift` |
| Data (저장소 구현) | `<저장방식><Noun>Repository.swift` |
| Data (저장 모델) | `<Noun>Model.swift` |

저장소 구현체는 `...RepositoryImpl`이 아니라 **무엇으로 저장하는지**를 이름에 담는다(`SwiftDataBabyProfileRepository`, `InMemoryBabyProfileRepository`). 구현이 하나뿐일 거라는 가정을 하지 않게 되고, 실제로 두 구현이 공존한다.

### 교차 관심사는 어디로 가는가

**두 번째 사용처가 실제로 생기기 전까지는 `Shared/`로 올리지 않는다.** 소유한 Feature 안에 두고, 다른 Feature가 진짜로 필요로 하는 시점에 옮긴다. 미리 옮겨두면 "공유되고 있다"는 잘못된 신호를 준다.

`App/`이 여러 Feature를 참조하는 것은 예외다. 조립이 App 계층의 역할이므로 Feature 간 참조로 보지 않는다.

**표시 문구·색상 매핑은 Presentation에 둔다.** 도메인 타입이 "화면에 어떻게 보일지"를 알면 안 된다. 예를 들어 `Gender`는 `male`/`female`만 알고, "남자"/"여자"는 `Gender+Display.swift`가 안다. 같은 이유로 `ForEach` 편의를 위한 `Identifiable` 채택처럼 뷰 사정으로 생긴 요구사항도 도메인에 넣지 않는다.

## 의존성 규칙

- **Domain**: `Foundation`만 import. `SwiftUI`, `Combine`, `SwiftData`, `UIKit`, 서드파티 SDK import 금지. 비동기는 `async/await`와 `AsyncStream`만 쓴다 — 프로젝트가 이미 `SWIFT_APPROACHABLE_CONCURRENCY` / `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`로 Swift 6 동시성 모델을 채택했으므로 Combine을 섞지 않는다.
  - 단, `Codable` 채택은 허용한다. 이 enum들은 이미 `String` rawValue를 갖고 있어 직렬화 가능한 형태를 받아들인 상태이고, rawValue를 별도 보관해 매핑하는 방식은 실제로 일어나지 않는 실패 경로(옵셔널)를 저장소까지 번지게 만들었다.
- **Presentation**: `SwiftUI` + Domain만 import. ViewModel은 Domain 프로토콜만 생성자로 주입받고 구현체를 직접 알지 못한다. 비동기 처리는 ViewModel이 맡고, 뷰에는 `Task { await ... }`를 두지 않는다.
- **Data**: Domain 프로토콜을 준수하기 위한 import + 영속성/SDK 프레임워크. `SwiftUI` import 금지.
- 하나의 앱 타겟 안에서 폴더로만 나눈 구조이므로 Feature 간 격리는 **컴파일러가 강제하지 않는다.** 코드 리뷰로 지켜야 하는 컨벤션이라는 점을 인지하고 간다.

### 저장소는 변경을 스트림으로 알린다

조회용 단발 메서드 대신 `AsyncStream`을 노출한다. 구독하면 현재 값을 즉시 방출하고, 이후 변경될 때마다 방출한다.

```swift
protocol BabyProfileRepository: Sendable {
    func stream() -> AsyncStream<BabyProfile?>
    func register(_ profile: BabyProfile) async throws
}
```

쓰기가 일어난 사실을 화면에 알리려고 콜백을 손으로 연결하지 않아도 된다. 쓰는 곳이 늘어나도 구독자는 자동으로 최신 상태를 받는다.

## DI 방식

서드파티 DI 프레임워크 없이 수동 생성자 주입 + 단일 컴포지션 루트를 쓴다.

```swift
// App/AppDependencyContainer.swift
@MainActor
final class AppDependencyContainer {
    private let babyProfileRepository: BabyProfileRepository

    init() throws {
        let modelContainer = try ModelContainer(for: BabyProfileModel.self)
        babyProfileRepository = SwiftDataBabyProfileRepository(modelContainer: modelContainer)
    }

    /// 실제 저장소를 쓰지 않는 Preview용.
    init(babyProfileRepository: BabyProfileRepository) {
        self.babyProfileRepository = babyProfileRepository
    }

    func makeRootViewModel() -> RootViewModel {
        RootViewModel(repository: babyProfileRepository)
    }
}
```

`RootView`는 컨테이너 전체를 `.environment()`로 뿌리지 않고, 화면마다 필요한 `make*ViewModel()` 팩토리만 호출한다. 컨테이너를 통째로 넘기면 아무 화면이나 관계없는 의존성에 접근할 수 있게 되어 계층 분리 의미가 없어진다.

**사소한 동작에는 UseCase를 만들지 않는다.** 단순 pass-through 동작은 ViewModel이 Repository 프로토콜을 바로 호출해도 된다. UseCase는 실제로 조합·검증 로직이 있을 때만 도입한다. 아기 등록 기능은 조회·등록 모두 단순 위임이라 UseCase를 두지 않았다.

**시작에 실패하면 크래시시키지 않는다.** `ModelContainer` 생성이 실패하면 `try!` 대신 안내 화면(`StorageUnavailableView`)을 띄우고 원인은 `OSLog`로 남긴다. 화면은 사용자가 할 수 있는 안내만 담고, 기술적 오류는 로그로 분리한다.

## 다국어

한국어(소스 언어), 영어, 일본어, 중국어 간체를 지원한다.

- 번역 키는 **한국어 문자열 그대로** 쓴다. `Text("남자")`처럼 코드에 한국어를 두고 String Catalog가 키로 추출한다.
- 표시 문구는 `String`이 아니라 `LocalizedStringKey`로 노출한다. `String`을 `Text`에 넘기면 번역하지 않는 오버로드가 선택되어 로컬라이징이 조용히 무력화된다.
- 번역은 `MyiR/Localizable.xcstrings` 한 곳에서 관리한다.

## Consequences

**얻는 것**
- Data 구현체 교체가 쉽다. 인메모리 저장소를 SwiftData로 바꿀 때 **테스트 15개를 한 줄도 고치지 않고 통과**했고 Presentation/Domain도 손대지 않았다.
- Feature가 물리적으로 분리돼 있어 2인 팀의 병렬 작업이 쉬움
- 저장소 프로토콜 덕분에 가짜 저장소를 끼워 ViewModel을 실제 저장소 없이 테스트 가능
- 계층 단위로 커밋을 쪼갤 수 있어 히스토리에서 변경 범위가 드러남

**드는 비용**
- 작은 Feature에도 계층별 파일이 여러 개 생김 (UseCase 생략 규칙으로 일부 완화)
- 하나의 앱 타겟이라 Feature 경계가 컴파일러가 아닌 리뷰 규율에 의존
- 수동 DI 컨테이너는 Feature가 늘어날수록 관리가 필요
- 지금 앱 규모에 비해 구조가 다소 무거울 수 있음 — 팀이 명시적으로 Clean Architecture를 요청했고, 앞으로 붙을 인증/분석 백엔드의 리스크를 미리 낮추기 위해 감수하는 트레이드오프로 채택

## Open Questions / Future Considerations

- Home 기록(기저귀·수유·수면 등) 저장 모델 설계 — 아기 정보는 SwiftData로 정해졌으나 기록은 데이터 양과 조회 패턴이 달라 별도 검토 필요
- Analysis의 실제 울음 분석 방식(온디바이스 CoreML vs 서버 API) 미정 — `Core/Networking` 신설 여부와 액터 격리 방식에 영향
- 원본 앱은 Firebase 기반이나 이 프로젝트의 백엔드 연동 여부·시점 미정
- 번역 문구 원어민 검수 필요 (현재 번역은 미검수)
- Feature 수가 늘어나면 로컬 SPM 패키지로 물리적 분리하는 것을 검토

## 변경 이력

- 2026-08-27: 최초 작성 — Clean Architecture + Feature-first 구조 채택
- 2026-08-28: 아기 등록 기능 구현 결과 반영 — 실제 폴더 구조, 저장소 스트림 패턴, SwiftData 채택, 다국어, 테스트 구조, `Shared/` 이동 기준 추가
