//
//  PaginationSinkTests.swift
//  FlickrViewerTests
//
//  Created by Yan Schneider on 1.05.21.
//

import XCTest
import RxTest
import RxSwift
import Nimble

@testable import FlickrViewer

class PaginationSinkTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var subscription: Disposable!
    
    override func setUp() {
        super.setUp()
        
        scheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        scheduler.scheduleAt(1000) {
            self.subscription.dispose()
        }

        scheduler = nil
        super.tearDown()
    }

    func test_loadingFirstPage() {
        let sink = PaginationSink<Int>()
        let next = PublishSubject<Void>()
        let pagination = sink.pagination(task: { page, numberOfItems in
            .just(([1, 2, 3], 9))
        }, reset: .empty(), next: next.asObservable())
        let paginationObserver = scheduler.createObserver([Int].self)
        subscription = pagination.subscribe(paginationObserver)
        
        scheduler.start()
        next.onNext(())
        
        let results = paginationObserver.events.compactMap {
          $0.value.element
        }
        expect(results).to(haveCount(1))
        expect(results[0]).to(equal([1, 2, 3]))
    }
    
    func test_loadingAllPages() {
        let sink = PaginationSink<Int>()
        let next = PublishSubject<Void>()
        let pages = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
        let totalItems = pages.flatMap { $0 }.count
        let pagination = sink.pagination(task: { page, numberOfItems in
            .just((pages[page], totalItems))
        }, reset: .empty(), next: next.asObservable(), numberOfItems: 3)
        let paginationObserver = scheduler.createObserver([Int].self)
        subscription = pagination.subscribe(paginationObserver)
        
        scheduler.start()
        next.onNext(())
        next.onNext(())
        next.onNext(())
        
        let results = paginationObserver.events.compactMap {
          $0.value.element
        }
        expect(results).to(haveCount(3))
        expect(results[0]).to(equal([1, 2, 3]))
        expect(results[1]).to(equal([1, 2, 3, 4, 5, 6]))
        expect(results[2]).to(equal([1, 2, 3, 4, 5, 6, 7, 8, 9]))
    }
}
