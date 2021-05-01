//
//  SaveModelUseCase.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 1.05.21.
//

import Foundation
import RxSwift

protocol SaveModelGateway {
    associatedtype Model
    func save(object: Model) -> Single<Result<Void, Error>>
}

struct SaveModelUseCase<Gateway: SaveModelGateway> {
    let gateway: Gateway
}

// MARK: - UseCaseType
extension SaveModelUseCase: UseCaseType {
    
    struct Input {
        let model: Observable<Gateway.Model>
    }
    
    struct Output {
        let errors: Observable<Error>
    }
    
    func execute(input: Input) -> Output {
        let errors = input.model.flatMap { object in
            gateway.save(object: object)
        }.compactMap { result -> Error? in
            guard case let .failure(error) = result else { return nil }
            return error
        }
        
        return .init(errors: errors)
    }
}
