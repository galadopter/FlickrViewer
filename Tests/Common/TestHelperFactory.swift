//
//  TestHelperFactory.swift
//  FlickrViewerTests
//
//  Created by Yan Schneider on 28.04.21.
//

import Foundation
@testable import FlickrViewer

struct TestHelperFactory {
    
    static func photosPage(
        page: Int = 1,
        totalPages: Int = 2,
        perPage: Int = 16,
        totalPhotos: Int = 32,
        photos: [Photo] = photos(range: 1...16)
    ) -> PhotosPage {
        .init(
            page: page,
            totalPages: totalPages,
            perPage: perPage,
            totalPhotos: totalPhotos,
            photos: photos
        )
    }
    
    static func photos(
        range: ClosedRange<Int> = 1...2
    ) -> [Photo] {
        range.map { photo(id: String($0)) }
    }
    
    static func photo(
        id: String = "a",
        owner: String = "",
        secret: String = "",
        server: String = "",
        farm: Int = 0,
        title: String = ""
    ) -> Photo {
        .init(
            id: id,
            owner: owner,
            secret: secret,
            server: server,
            farm: farm,
            title: title
        )
    }
    
    static func error(
        message: String = ""
    ) -> Error {
        InternalError(
            message: message
        )
    }
}
