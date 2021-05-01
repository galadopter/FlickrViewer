//
//  Utils.swift
//  MinLeon
//
//  Created by Yan on 11/6/18.
//  Copyright © 2018 Itexus. All rights reserved.
//

import Foundation

struct Repositories {
    
    private static let searchHistoryURL: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("searchHistory.json")
    }()
    static let searchHistory: FilesRepository<SearchRecord> = {
        return try! FilesRepository(
            url: searchHistoryURL,
            fileManager: .default,
            encode: { model in
                let encoder = JSONEncoder()
                return try encoder.encode(model)
            },
            decode: { data in
                let decoder = JSONDecoder()
                return try decoder.decode([SearchRecord].self, from: data)
            })
    }()
}
