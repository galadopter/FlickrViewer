//
//  PhotosPageMapping.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 1.05.21.
//

import Foundation

extension PhotosPage {
    enum CodingKeys: String, CodingKey {
        case response = "photos", page, perPage = "perpage", totalPages = "pages", totalPhotos = "total", photos = "photo"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let page = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
        self.page = try page.decode(Int.self, forKey: .page)
        totalPages = try page.decode(Int.self, forKey: .totalPages)
        perPage = try page.decode(Int.self, forKey: .perPage)
        let total = try page.decode(String.self, forKey: .totalPhotos)
        totalPhotos = Int(total) ?? 0
        photos = try page.decode([Photo].self, forKey: .photos)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var page = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
        try page.encode(self.page, forKey: .page)
        try page.encode(totalPages, forKey: .totalPages)
        try page.encode(perPage, forKey: .perPage)
        try page.encode(totalPhotos, forKey: .totalPhotos)
        try page.encode(photos, forKey: .photos)
    }
}
