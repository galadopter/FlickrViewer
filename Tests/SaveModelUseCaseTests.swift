//
//  SaveModelUseCaseTests.swift
//  FlickrViewerTests
//
//  Created by Yan Schneider on 1.05.21.
//

import XCTest
import RxSwift
import RxTest
import Nimble

@testable import FlickrViewer

class SaveModelUseCaseTests: XCTestCase {

    func test_observingModels_shouldSucceed() {
        let gateway = SuccessMockSaveModelGateway<Int>()
        let useCase = SaveModelUseCase(gateway: gateway)
        let interface = MockInterface<SuccessMockSaveModelGateway<Int>>()
        let recorder = SaveModelUseCaseRecorder(useCase: useCase, input: interface.mapToInput())
        
        recorder.start()
        interface.modelSubject.onNext(1)
        interface.modelSubject.onNext(2)
        
        recorder.eventsShouldEmitted(times: 0, recorder: \.errorsRecorder)
        expect(gateway.objects).to(haveCount(2))
        expect(gateway.objects[0]).to(equal(1))
        expect(gateway.objects[1]).to(equal(2))
    }
    
    func test_observingModels_shouldFail() {
        let interface = MockInterface<FailureMockSaveModelGateway<Void>>()
        let gateway = FailureMockSaveModelGateway<Void>()
        let useCase = SaveModelUseCase(gateway: gateway)
        let recorder = SaveModelUseCaseRecorder(useCase: useCase, input: interface.mapToInput())
        
        recorder.start()
        interface.modelSubject.onNext(())
        
        recorder.eventsShouldEmitted(times: 1, recorder: \.errorsRecorder)
    }
}

// MARK: Mocks
private extension SaveModelUseCaseTests {
    
    struct MockInterface<Gateway: SaveModelGateway> {
        let modelSubject = PublishSubject<Gateway.Model>()
        
        func mapToInput() -> SaveModelUseCase<Gateway>.Input {
            .init(model: modelSubject.asObservable())
        }
    }
    
    class SuccessMockSaveModelGateway<Model>: SaveModelGateway {
        var objects = [Model]()
        
        func save(object: Model) -> Single<Result<Void, Error>> {
            objects.append(object)
            return .just(.success(()))
        }
    }
    
    struct FailureMockSaveModelGateway<Model>: SaveModelGateway {
        
        func save(object: Model) -> Single<Result<Void, Error>> {
            .just(.failure(TestHelperFactory.error()))
        }
    }
}
