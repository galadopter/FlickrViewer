//
//  ViewModelType.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 30.04.21.
//

import RxCocoa

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
