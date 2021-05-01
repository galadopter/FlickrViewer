//
//  GetPhotosUseCase.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 28.04.21.
//

import Foundation
import RxSwift

protocol GetPhotosGateway {
    func getPhotos(searchText: String, page: Int, perPage: Int) -> Single<Result<PhotosPage, Error>>
}

struct GetPhotosUseCase {
    let gateway: GetPhotosGateway
    let paginationSink: PaginationSink<Photo>
    let numberOfPhotosPerPage: Int
}

// MARK: - UseCaseType
extension GetPhotosUseCase: UseCaseType {
    
    struct Input {
        let searchText: Observable<String>
        let loadNextPage: Observable<Void>
    }
    
    struct Output {
        let photos: Observable<[Photo]>
        let errors: Observable<Error>
        let isLoading: Observable<Bool>
    }
    
    func execute(input: Input) -> Output {
        let text = input.searchText.share()
        let emptyPhotos = text.filter { $0.isEmpty }.map { _ in [Photo]() }
        let photos = getPhotos(searchText: text.filter { !$0.isEmpty }, loadNextPage: input.loadNextPage)
        let errors = paginationSink.errors
        let isLoading = paginationSink.isLoading
        
        return .init(photos: .merge(photos, emptyPhotos), errors: errors, isLoading: isLoading)
    }
    
    private func getPhotos(searchText: Observable<String>, loadNextPage: Observable<Void>) -> Observable<[Photo]> {
        return searchText.flatMapLatest { text -> Observable<[Photo]> in
            paginationSink.pagination(
                task: { (page, numberOfItems) -> Observable<(results: [Photo], totalCount: Int)> in
                    unwrapResult(gateway.getPhotos(searchText: text, page: page, perPage: numberOfItems))
                        .map { ($0.photos, $0.totalPhotos) }
                        .asObservable()
                },
                reset: .empty(),
                next: loadNextPage,
                numberOfItems: numberOfPhotosPerPage
            )
        }.share()
    }
}
