//
//  HistoryViewModel.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 1.05.21.
//

import Foundation
import RxSwift
import RxCocoa

extension FilesRepository: ObserveModelChangesGateway {
    
    func observe() -> Observable<Result<[Model], Error>> {
        observe()
            .map { .success($0) }
            .catch { .just(.failure($0)) }
    }
}

class HistoryViewModel {
    private let observeModelsUseCase: ObserveModelChangesUseCase<FilesRepository<SearchRecord>>
    
    init() {
        observeModelsUseCase = ObserveModelChangesUseCase(gateway: Repositories.searchHistory)
    }
}

// MARK: - ViewModelType
extension HistoryViewModel: ViewModelType {
    
    typealias Input = Void
    
    struct Output {
        let errors: Signal<Error>
        let records: Driver<[String]>
    }
    
    func transform(input: Input) -> Output {
        let output = observeModelsUseCase.execute(input: input)
        let errors = output.errors.asSignal(onErrorJustReturn: EmptyError())
        let records = output.models.map { records in
            records.map { $0.text }.reversed()
        }.asDriver(onErrorJustReturn: [])
        
        return .init(errors: errors, records: records)
    }
}
