//
//  PhotosAPI.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 29.04.21.
//

import Foundation

enum PhotosAPI {
    case getPhotos(request: GetPhotosRequest)
}

extension PhotosAPI: RequestType {
    
    var baseURL: URL {
        URL(string: "https://api.flickr.com/services/rest/")!
    }
    
    var path: String {
        switch self {
        case .getPhotos(let request):
            return "?method=flickr.photos.search&api_key=\(request.apiKey)&text=\(request.text)&per_page=\(request.perPage)&page=\(request.page)&format=json&nojsoncallback=1"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var headers: [String : String]? {
        nil
    }
}
