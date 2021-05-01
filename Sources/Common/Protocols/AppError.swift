//
//  AppError.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 30.04.21.
//

import Foundation

protocol AppError: Error {
    var message: String { get }
}

struct EmptyError: Error {
    
}

struct InternalError: AppError {
    let message: String
}
