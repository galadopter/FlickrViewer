//
//  SearchViewModel.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 30.04.21.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {
    private let getPhotosUseCase: GetPhotosUseCase
    
    init() {
        let sink = PaginationSink<Photo>()
        getPhotosUseCase = GetPhotosUseCase(gateway: PhotosService(), paginationSink: sink, numberOfPhotosPerPage: 16)
    }
}

// MARK: - ViewModelType
extension SearchViewModel: ViewModelType {
    
    struct Input {
        let text: Driver<String>
        let loadNextPage: Driver<Void>
    }
    
    struct Output {
        let errors: Signal<Error>
        let isLoading: Driver<Bool>
        let photos: Driver<[SearchedImageCellViewModel]>
    }
    
    func transform(input: Input) -> Output {
        let output = getPhotosUseCase.execute(input: input.useCaseInput)
        let getPhotoErrors = output.errors.asSignal(onErrorJustReturn: EmptyError())
        let fetchingPhotos = output.isLoading.asDriver(onErrorJustReturn: false)
        let photos = output.photos.asDriver(onErrorJustReturn: [])
            .map { [weak self] photos -> [SearchedImageCellViewModel] in
                guard let self = self else { return [] }
                return photos.compactMap { photo in
                    self.getImageURL(from: photo).map { url in
                        .init(imageURL: url, title: photo.title)
                    }
                }
            }
        
        return .init(errors: getPhotoErrors, isLoading: fetchingPhotos, photos: photos)
    }
}

// MARK: - Private
private extension SearchViewModel {
    
    func getImageURL(from photo: Photo) -> URL? {
        URL(string: "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")
    }
}

// MARK: - SearchViewModel.Input Mapping
extension SearchViewModel.Input {
    
    var useCaseInput: GetPhotosUseCase.Input {
        .init(searchText: optimizedText, loadNextPage: loadNextPage.asObservable())
    }
    
    var optimizedText: Observable<String> {
        text.distinctUntilChanged()
            .throttle(.milliseconds(300))
            .asObservable()
    }
}
