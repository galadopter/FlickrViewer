//
//  GetPhotosUseCaseTests.swift
//  FlickrViewerTests
//
//  Created by Yan Schneider on 30.04.21.
//

import XCTest
import RxSwift
import RxTest
import Nimble

@testable import FlickrViewer

class GetPhotosUseCaseTests: XCTestCase {
    
    func test_fetchingPhotos_shouldSucceed() {
        let page = TestHelperFactory.photosPage()
        let useCase = makeSUT(pages: [page])
        let interface = MockInterface()
        let recorder = GetPhotosUseCaseRecorder(useCase: useCase, input: interface.mapToInput())
        
        recorder.start()
        interface.searchTextSubject.onNext("some")
        interface.loadNextSubject.onNext(())
        
        recorder.eventsShouldEmitted(times: 3, recorder: \.isLoadingRecorder)
        recorder.eventsShouldEmitted(times: 1, recorder: \.photosRecorder)
        recorder.eventsShouldEmitted(times: 0, recorder: \.errorsRecorder)
        
        recorder.eventElementShouldBe(page.photos, at: 0, for: \.photosRecorder)
        recorder.eventElementShouldBe(false, at: 0, for: \.isLoadingRecorder)
        recorder.eventElementShouldBe(true, at: 1, for: \.isLoadingRecorder)
        recorder.eventElementShouldBe(false, at: 2, for: \.isLoadingRecorder)
    }
    
    func test_fetchingPhotosWithEmptyString_shouldReturnEmptyArray() {
        let page = TestHelperFactory.photosPage()
        let useCase = makeSUT(pages: [page])
        let interface = MockInterface()
        let recorder = GetPhotosUseCaseRecorder(useCase: useCase, input: interface.mapToInput())
        
        recorder.start()
        interface.searchTextSubject.onNext("")
        interface.loadNextSubject.onNext(())
        
        recorder.eventsShouldEmitted(times: 0, recorder: \.isLoadingRecorder)
        recorder.eventsShouldEmitted(times: 1, recorder: \.photosRecorder)
        recorder.eventsShouldEmitted(times: 0, recorder: \.errorsRecorder)
        
        recorder.eventElementShouldBe([], at: 0, for: \.photosRecorder)
    }
    
    func test_fetchingTwoPagesOfPhotos_shouldSucceed() {
        let firstPage = TestHelperFactory.photosPage(page: 0)
        let secondPage = TestHelperFactory.photosPage(page: 1, photos: TestHelperFactory.photos(range: 17...32))
        let useCase = makeSUT(pages: [firstPage, secondPage])
        let interface = MockInterface()
        let recorder = GetPhotosUseCaseRecorder(useCase: useCase, input: interface.mapToInput())
        
        recorder.start()
        interface.searchTextSubject.onNext("some")
        interface.loadNextSubject.onNext(())
        interface.loadNextSubject.onNext(())
        
        recorder.eventsShouldEmitted(times: 5, recorder: \.isLoadingRecorder)
        recorder.eventsShouldEmitted(times: 2, recorder: \.photosRecorder)
        recorder.eventsShouldEmitted(times: 0, recorder: \.errorsRecorder)
        
        recorder.eventElementShouldBe(firstPage.photos, at: 0, for: \.photosRecorder)
        recorder.eventElementShouldBe(firstPage.photos + secondPage.photos, at: 1, for: \.photosRecorder)
        recorder.eventElementShouldBe(false, at: 0, for: \.isLoadingRecorder)
        recorder.eventElementShouldBe(true, at: 1, for: \.isLoadingRecorder)
        recorder.eventElementShouldBe(false, at: 2, for: \.isLoadingRecorder)
        recorder.eventElementShouldBe(true, at: 3, for: \.isLoadingRecorder)
        recorder.eventElementShouldBe(false, at: 4, for: \.isLoadingRecorder)
    }
    
    func test_selectingAnotherText_shouldSucceed() {
        let page = TestHelperFactory.photosPage()
        let useCase = makeSUT(pages: [page])
        let interface = MockInterface()
        let recorder = GetPhotosUseCaseRecorder(useCase: useCase, input: interface.mapToInput())
        
        recorder.start()
        interface.searchTextSubject.onNext("some")
        interface.loadNextSubject.onNext(())
        
        interface.searchTextSubject.onNext("another")
        interface.loadNextSubject.onNext(())
        
        recorder.eventsShouldEmitted(times: 6, recorder: \.isLoadingRecorder)
        recorder.eventsShouldEmitted(times: 3, recorder: \.photosRecorder)
        recorder.eventsShouldEmitted(times: 0, recorder: \.errorsRecorder)
        
        recorder.eventElementShouldBe(page.photos, at: 0, for: \.photosRecorder)
        recorder.eventElementShouldBe([], at: 1, for: \.photosRecorder)
        recorder.eventElementShouldBe(page.photos, at: 2, for: \.photosRecorder)
    }
    
    func test_fetchingPhotos_shouldFail() {
        let gateway = FailureMockGetPhotosGateway()
        let sink = PaginationSink<Photo>()
        let useCase = GetPhotosUseCase(gateway: gateway, paginationSink: sink, numberOfPhotosPerPage: 16)
        let interface = MockInterface()
        let recorder = GetPhotosUseCaseRecorder(useCase: useCase, input: interface.mapToInput())
        
        recorder.start()
        interface.searchTextSubject.onNext("some")
        interface.loadNextSubject.onNext(())
        
        recorder.eventsShouldEmitted(times: 3, recorder: \.isLoadingRecorder)
        recorder.eventsShouldEmitted(times: 0, recorder: \.photosRecorder)
        recorder.eventsShouldEmitted(times: 1, recorder: \.errorsRecorder)
        
        recorder.eventElementShouldBe(false, at: 0, for: \.isLoadingRecorder)
        recorder.eventElementShouldBe(true, at: 1, for: \.isLoadingRecorder)
        recorder.eventElementShouldBe(false, at: 2, for: \.isLoadingRecorder)
    }
    
    private func makeSUT(pages: [PhotosPage], numberOfPhotosPerPage: Int = 16) -> GetPhotosUseCase {
        let gateway = SuccessMockGetPhotosGateway(photosPages: pages)
        let sink = PaginationSink<Photo>()
        
        return GetPhotosUseCase(
            gateway: gateway,
            paginationSink: sink,
            numberOfPhotosPerPage: numberOfPhotosPerPage
        )
    }
}

// MARK: Mocks
private extension GetPhotosUseCaseTests {
    
    struct MockInterface {
        let searchTextSubject = PublishSubject<String>()
        let loadNextSubject = PublishSubject<Void>()
        
        func mapToInput() -> GetPhotosUseCase.Input {
            .init(
                searchText: searchTextSubject.asObservable(),
                loadNextPage: loadNextSubject.asObservable()
            )
        }
    }
    
    struct SuccessMockGetPhotosGateway: GetPhotosGateway {
        let photosPages: [PhotosPage]
        
        func getPhotos(searchText: String, page: Int, perPage: Int) -> Single<Result<PhotosPage, Error>> {
            .just(.success(photosPages[page]))
        }
    }
    
    struct FailureMockGetPhotosGateway: GetPhotosGateway {
        
        func getPhotos(searchText: String, page: Int, perPage: Int) -> Single<Result<PhotosPage, Error>> {
            .just(.failure(TestHelperFactory.error()))
        }
    }
}
