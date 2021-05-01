//
//  GetPhotosRequest.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 29.04.21.
//

import Foundation

struct GetPhotosRequest: Codable {
    let apiKey: String
    let text: String
    let page: Int
    let perPage: Int
}
