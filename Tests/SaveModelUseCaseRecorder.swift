//
//  SaveModelUseCaseRecorder.swift
//  FlickrViewerTests
//
//  Created by Yan Schneider on 1.05.21.
//

import Nimble
import RxSwift
import RxTest

@testable import FlickrViewer

class SaveModelUseCaseRecorder<Gateway: SaveModelGateway>: Recorder {
    private let useCase: SaveModelUseCase<Gateway>
    private let scheduler = TestScheduler(initialClock: 0)
    private let bag = DisposeBag()

    lazy var errorsRecorder: TestableObserver = {
        scheduler.createObserver(Error.self)
    }()
    
    init(useCase: SaveModelUseCase<Gateway>, input: SaveModelUseCase<Gateway>.Input) {
        self.useCase = useCase
        let output = useCase.execute(input: input)
        
        bag.insert([
            output.errors.bind(to: errorsRecorder)
        ])
    }
    
    func start() {
        scheduler.start()
    }
}
