//
//  SearchViewModel.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 30.04.21.
//

import Foundation
import RxSwift
import RxCocoa

extension FilesRepository: SaveModelGateway {
    
    func save(object: Model) -> Single<Result<Void, Error>> {
        save(objects: [object])
            .map { .success($0) }
            .catch { .just(.failure($0)) }
    }
}

class SearchViewModel {
    private let getPhotosUseCase: GetPhotosUseCase
    private let saveHistoryUseCase: SaveModelUseCase<FilesRepository<SearchRecord>>
    
    init() {
        let sink = PaginationSink<Photo>()
        getPhotosUseCase = GetPhotosUseCase(gateway: PhotosService(), paginationSink: sink, numberOfPhotosPerPage: 16)
        saveHistoryUseCase = SaveModelUseCase(gateway: Repositories.searchHistory)
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
        let getPhotosOutput = getPhotosUseCase.execute(input: input.getPhotosUseCaseInput)
        let getPhotoErrors = getPhotosOutput.errors.asSignal(onErrorJustReturn: EmptyError())
        let fetchingPhotos = getPhotosOutput.isLoading.asDriver(onErrorJustReturn: false)
        let photos = getPhotosOutput.photos.asDriver(onErrorJustReturn: [])
            .map { [weak self] photos -> [SearchedImageCellViewModel] in
                guard let self = self else { return [] }
                return photos.compactMap { photo in
                    self.getImageURL(from: photo).map { url in
                        .init(imageURL: url, title: photo.title)
                    }
                }
            }

        let saveHistoryOutput = saveHistoryUseCase.execute(input: input.saveHistoryUseCaseInput)
        let saveHistoryErrors = saveHistoryOutput.errors.asSignal(onErrorJustReturn: EmptyError())
        
        return .init(errors: .merge(getPhotoErrors, saveHistoryErrors), isLoading: fetchingPhotos, photos: photos)
    }
}

// MARK: - Private
private extension SearchViewModel {
    
    func getImageURL(from photo: Photo) -> URL? {
        URL(string: "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")
    }
}

// MARK: - Use Case Inputs Mapping
extension SearchViewModel.Input {
    
    var getPhotosUseCaseInput: GetPhotosUseCase.Input {
        .init(
            searchText: text.asObservable(),
            loadNextPage: loadNextPage.asObservable()
        )
    }
    
    var saveHistoryUseCaseInput: SaveModelUseCase<FilesRepository<SearchRecord>>.Input {
        .init(model: text.filter { !$0.isEmpty }.map { SearchRecord(text: $0) }.asObservable())
    }
}
