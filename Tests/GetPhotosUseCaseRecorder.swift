//
//  GetPhotosUseCaseRecorder.swift
//  FlickrViewerTests
//
//  Created by Yan Schneider on 30.04.21.
//

import Nimble
import RxSwift
import RxTest

@testable import FlickrViewer

class GetPhotosUseCaseRecorder: Recorder {
    private let useCase: GetPhotosUseCase
    private let scheduler = TestScheduler(initialClock: 0)
    private let bag = DisposeBag()
    
    lazy var photosRecorder: TestableObserver = {
        scheduler.createObserver([Photo].self)
    }()
    lazy var errorsRecorder: TestableObserver = {
        scheduler.createObserver(Error.self)
    }()
    lazy var isLoadingRecorder: TestableObserver = {
        scheduler.createObserver(Bool.self)
    }()
    
    init(useCase: GetPhotosUseCase, input: GetPhotosUseCase.Input) {
        self.useCase = useCase
        let output = useCase.execute(input: input)
        
        bag.insert([
            output.photos.bind(to: photosRecorder),
            output.errors.bind(to: errorsRecorder),
            output.isLoading.bind(to: isLoadingRecorder)
        ])
    }
    
    func start() {
        scheduler.start()
    }
}
