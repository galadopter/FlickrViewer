//
//  ObserveModelChangesUseCaseRecorder.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 1.05.21.
//

import Nimble
import RxSwift
import RxTest

@testable import FlickrViewer

class ObserveModelChangesUseCaseRecorder<Gateway: ObserveModelChangesGateway>: Recorder {
    private let useCase: ObserveModelChangesUseCase<Gateway>
    private let scheduler = TestScheduler(initialClock: 0)
    private let bag = DisposeBag()
    
    lazy var modelsRecorder: TestableObserver = {
        scheduler.createObserver([Gateway.Model].self)
    }()
    lazy var errorsRecorder: TestableObserver = {
        scheduler.createObserver(Error.self)
    }()
    
    init(useCase: ObserveModelChangesUseCase<Gateway>, input: ObserveModelChangesUseCase<Gateway>.Input) {
        self.useCase = useCase
        let output = useCase.execute(input: input)
        
        bag.insert([
            output.models.bind(to: modelsRecorder),
            output.errors.bind(to: errorsRecorder)
        ])
    }
    
    func start() {
        scheduler.start()
    }
}
