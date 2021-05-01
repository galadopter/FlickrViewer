//
//  SearchRecord.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 1.05.21.
//

import Foundation

struct SearchRecord: Codable, Identifiable {
    let id: String
    let text: String
    
    init(id: String = UUID().uuidString, text: String) {
        self.id = id
        self.text = text
    }
}
