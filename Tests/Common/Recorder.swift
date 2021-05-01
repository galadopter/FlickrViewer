//
//  Recorder.swift
//  FlickrViewerTests
//
//  Created by Yan Schneider on 28.04.21.
//

import Nimble
import RxTest
import Foundation

public protocol Recorder { }

extension Recorder {

    public func eventsShouldEmitted<T>(times: Int, recorder: KeyPath<Self, TestableObserver<T>>,
                                       timeout: DispatchTimeInterval = AsyncDefaults.timeout, eventName: String? = nil,
                                       file: FileString = #file, line: UInt = #line) {
        let name = eventName ?? String(describing: recorder)
        expect(file: file, line: line, self[keyPath: recorder].events).toEventually(haveCount(times), timeout: timeout, description: "\(name) should have \(times) events")
    }

    public func eventsShouldNotEmitted<T>(recorder: KeyPath<Self, TestableObserver<T>>, eventName: String? = nil,
                                file: FileString = #file, line: UInt = #line) {
        let name = eventName ?? String(describing: recorder)
        expect(file: file, line: line, self[keyPath: recorder].events).to(haveCount(0), description: "\(name) shouldn't have any events")
    }
    
    public func eventShouldBeCompleted<T: Equatable>(at order: Int, for recorder: KeyPath<Self, TestableObserver<T>>, file: FileString = #file, line: UInt = #line) {
        expect(file: file, line: line, self[keyPath: recorder].events[order].value).to(equal(.completed))
    }

    public func eventElementShouldBe<T: Equatable>(_ element: T, at order: Int, for recorder: KeyPath<Self, TestableObserver<T>>,
                                            file: FileString = #file, line: UInt = #line) {
        expect(file: file, line: line, self[keyPath: recorder].events[order].value.element).to(equal(element))
    }

    public func eventElementShouldBe<T, U: Equatable>(_ element: U, at order: Int, for recorder: KeyPath<Self, TestableObserver<T>>,
                                               elementKeyPath: KeyPath<T, U>, file: FileString = #file, line: UInt = #line) {
        let sequenceElement = self[keyPath: recorder].events[order].value.element
        expect(file: file, line: line, sequenceElement).notTo(beNil())
        expect(file: file, line: line, sequenceElement?[keyPath: elementKeyPath]).to(equal(element))
    }

    public func eventElementShouldBe<T, U: Equatable>(_ element: U, at order: Int, for recorder: KeyPath<Self, TestableObserver<T?>>,
                                               elementKeyPath: KeyPath<T, U>, file: FileString = #file, line: UInt = #line) {
        let sequenceElement = self[keyPath: recorder].events[order].value.element
        expect(file: file, line: line, sequenceElement).notTo(beNil())
        expect(file: file, line: line, sequenceElement??[keyPath: elementKeyPath]).to(equal(element))
    }

    public func eventElementShouldNotBeNil<T>(at order: Int, for recorder: KeyPath<Self, TestableObserver<T>>,
                                       file: FileString = #file, line: UInt = #line) {
        expect(file: file, line: line, self[keyPath: recorder].events[order].value.element).notTo(beNil())
    }

    public func eventElementShouldBeNil<T, U: Equatable>(at order: Int,
                                    for recorder: KeyPath<Self, TestableObserver<T?>>,
                                    file: FileString = #file,
                                    line: UInt = #line,
                                    elementKeyPath: KeyPath<T, U>) {
        let sequenceElement = self[keyPath: recorder].events[order].value.element
        expect(file: file, line: line, sequenceElement).notTo(beNil())
        expect(file: file, line: line, sequenceElement??[keyPath: elementKeyPath]).to(beNil())
    }
}

