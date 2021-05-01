//
//  Photo.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 28.04.21.
//

import Foundation

struct Photo: Codable, Hashable, Equatable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
}
