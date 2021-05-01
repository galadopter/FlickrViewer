//
//  PhotosService.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 29.04.21.
//

import Foundation
import RxSwift

class PhotosService: NetworkService<PhotosAPI>, GetPhotosGateway {
    
    func getPhotos(searchText: String, page: Int, perPage: Int) -> Single<Result<PhotosPage, Error>> {
        let request = GetPhotosRequest(apiKey: Credentials.apiKey, text: searchText, page: page + 1, perPage: perPage)
        return network.fetch(.getPhotos(request: request))
    }
}
