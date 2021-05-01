//
//  RepositoryType.swift
//  MinLeon
//
//  Created by Yan on 11/6/18.
//  Copyright © 2018 Itexus. All rights reserved.
//

import RxSwift

protocol RepositoryType {
    associatedtype Model: Identifiable
    func observe() -> Observable<[Model]>
    func save(objects: [Model]) -> Single<Void>
}
