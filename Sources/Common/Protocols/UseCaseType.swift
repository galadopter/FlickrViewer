//
//  UseCaseType.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 30.04.21.
//

import Foundation

protocol UseCaseType {
    associatedtype Input
    associatedtype Output
    
    func execute(input: Input) -> Output
}
