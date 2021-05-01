//
//  Network.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 29.04.21.
//

import Foundation
import RxSwift

final class Network<API: RequestType> {
    
    private let session: URLSession
    
    private enum Errors: Error {
        case incorrectRequest
    }
    
    init(session: URLSession = .shared, shouldLogRequests: Bool = false) {
        URLSession.rx.shouldLogRequest = { _ in shouldLogRequests }
        self.session = session
    }
    
    func fetch<T: Decodable>(_ api: API, decoder: JSONDecoder = .init()) -> Single<Result<T, Error>> {
        guard let request = URLRequest(from: api) else { return .just(.failure(Errors.incorrectRequest)) }
        return session.rx.data(request: request)
            .map { data in
                Result {
                    try decoder.decode(T.self, from: data)
                }
            }.catch { .just(.failure($0)) }
            .asSingle()
    }
}
