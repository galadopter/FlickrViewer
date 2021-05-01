//
//  ObserveModelChangesUseCase.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 1.05.21.
//

import Foundation
import RxSwift

protocol ObserveModelChangesGateway {
    associatedtype Model
    func observe() -> Observable<Result<[Model], Error>>
}

struct ObserveModelChangesUseCase<Gateway: ObserveModelChangesGateway> {
    let gateway: Gateway
}

// MARK: - UseCaseType
extension ObserveModelChangesUseCase: UseCaseType {
    
    typealias Input = Void
    
    struct Output {
        let models: Observable<[Gateway.Model]>
        let errors: Observable<Error>
    }
    
    func execute(input: Input) -> Output {
        let results = gateway.observe().share()
        let models = results.compactMap { try? $0.get() }
        let errors = results.compactMap { result -> Error? in
            guard case let .failure(error) = result else { return nil }
            return error
        }
        
        return .init(models: models, errors: errors)
    }
}
