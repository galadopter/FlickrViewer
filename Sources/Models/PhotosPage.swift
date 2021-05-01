//
//  PhotosPage.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 28.04.21.
//

import Foundation

struct PhotosPage: Codable, Equatable {
    let page: Int
    let totalPages: Int
    let perPage: Int
    let totalPhotos: Int
    let photos: [Photo]
}
