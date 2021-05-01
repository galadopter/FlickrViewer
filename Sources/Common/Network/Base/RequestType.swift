//
//  RequestType.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 29.04.21.
//

import Foundation

protocol RequestType {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
}

enum HTTPMethod: String {
    case get, post, put, delete, patch
    
    var value: String {
        rawValue.uppercased()
    }
}

extension URLRequest {
    
    init?<API: RequestType>(from api: API) {
        guard let path = api.baseURL.appendingPathComponent(api.path).absoluteString.removingPercentEncoding,
              let url = URL(string: path) else { return nil }
        self.init(url: url)
        httpMethod = api.method.value
        allHTTPHeaderFields = api.headers
    }
}
