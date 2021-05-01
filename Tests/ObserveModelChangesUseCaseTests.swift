//
//  ObserveModelChangesUseCaseTests.swift
//  FlickrViewerTests
//
//  Created by Yan Schneider on 1.05.21.
//

import XCTest
import RxSwift
import RxTest
import Nimble

@testable import FlickrViewer

class ObserveModelChangesUseCaseTests: XCTestCase {

    func test_observingModels_shouldSucceed() {
        let gateway = SuccessMockObserveModelGateway(modelsSubject: .init(value: [1, 2, 3]))
        let useCase = ObserveModelChangesUseCase(gateway: gateway)
        let recorder = ObserveModelChangesUseCaseRecorder(useCase: useCase, input: ())
        
        recorder.start()
        gateway.modelsSubject.onNext([3, 4, 5])
        gateway.modelsSubject.onNext([6, 7, 8])
        
        recorder.eventsShouldEmitted(times: 3, recorder: \.modelsRecorder)
        recorder.eventsShouldEmitted(times: 0, recorder: \.errorsRecorder)
        
        recorder.eventElementShouldBe([1, 2, 3], at: 0, for: \.modelsRecorder)
        recorder.eventElementShouldBe([3, 4, 5], at: 1, for: \.modelsRecorder)
        recorder.eventElementShouldBe([6, 7, 8], at: 2, for: \.modelsRecorder)
    }
    
    func test_observingModels_shouldFail() {
        let gateway = FailureMockObserveModelGateway<Void>()
        let useCase = ObserveModelChangesUseCase(gateway: gateway)
        let recorder = ObserveModelChangesUseCaseRecorder(useCase: useCase, input: ())
        
        recorder.start()
        
        recorder.eventsShouldEmitted(times: 1, recorder: \.modelsRecorder)
        recorder.eventsShouldEmitted(times: 2, recorder: \.errorsRecorder)
    }
}

// MARK: Mocks
private extension ObserveModelChangesUseCaseTests {
    
    struct SuccessMockObserveModelGateway<Model>: ObserveModelChangesGateway {
        let modelsSubject: BehaviorSubject<[Model]>
        
        func observe() -> Observable<Result<[Model], Error>> {
            modelsSubject.asObservable().map { .success($0) }
        }
    }
    
    struct FailureMockObserveModelGateway<Model>: ObserveModelChangesGateway {
        
        func observe() -> Observable<Result<[Model], Error>> {
            .just(.failure(TestHelperFactory.error()))
        }
    }
}
