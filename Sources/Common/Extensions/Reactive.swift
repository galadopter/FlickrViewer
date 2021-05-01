//
//  Reactive.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 28.04.21.
//

import RxSwift

func unwrapResult<ResultValue, Error: Swift.Error, O: ObservableConvertibleType>(_ observable: O) -> Observable<ResultValue>
    where O.Element == Result<ResultValue, Error> {
        
    return observable.asObservable().map { result in
        switch result {
        case .failure(let error):
            throw error
        case .success(let value):
            return value
        }
    }
}
