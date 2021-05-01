//
//  PaginationSink.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 28.04.21.
//

import RxSwift
import RxRelay

public class PaginationSink<T> {
    
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorsRelay = PublishRelay<Error>()
    
    fileprivate let items = BehaviorRelay<[T]>(value: [])
    private let totalCount = BehaviorRelay<Int>(value: 0)
    
    public var isLoading: Observable<Bool> {
        isLoadingRelay.asObservable().skip(1)
    }
    
    public var errors: Observable<Error> {
        errorsRelay.asObservable()
    }
    
    private var disposeBag = DisposeBag()
    
    public init() { }
    
    public func pagination(task: @escaping ((page: Int, numberOfItems: Int)) -> Observable<(results: [T], totalCount: Int)>,
                           reset: Observable<Void>,
                           next: Observable<Void>,
                           numberOfItems: Int = 10) -> Observable<[T]> {
        
        disposeBag = DisposeBag()
        isLoadingRelay.accept(false)
        items.accept([])
        totalCount.accept(0)
        
        let isAllLoaded = Observable.combineLatest(items.skip(1).map(\.count).startWith(-1), totalCount)
            .map { $0 >= $1 }
            .share()
        
        let next: Observable<Void> = next.withLatestFrom(isAllLoaded)
            .filter(!)
            .withLatestFrom(isLoadingRelay)
            .filter(!)
            .map { _ in true }
            .do(onNext: isLoadingRelay.accept)
            .map { _ in }
            .share()
        
        let reset: Observable<Void> = reset
            .map { _ in true }
            .do(onNext: isLoadingRelay.accept)
            .map { _ in [] }
            .do(onNext: items.accept)
            .map { _ in }
            .share()
        
        let response = Observable<Void>.merge(reset, next)
            .withLatestFrom(items)
            .map { items in
                items.count / numberOfItems
            }
            .flatMapLatest { page in
                task((page: page, numberOfItems: numberOfItems))
                    .map { (results, totalCount) in
                        return (results: results, totalCount: totalCount, page: page)
                    }
                    .catch { [weak self] error in
                        self?.isLoadingRelay.accept(false)
                        self?.errorsRelay.accept(error)
                        return .never()
                    }
            }
            .share()
        
        response
            .map({ $0.totalCount })
            .bind(to: totalCount)
            .disposed(by: disposeBag)
        
        response
            .map { _ in false }
            .bind(to: isLoadingRelay)
            .disposed(by: disposeBag)
        
        response
            .withLatestFrom(items) { ($0, $1) }
            .map { response, items -> [T] in
                if response.page > 0 {
                    return items + response.results
                } else {
                    return response.results
                }
            }
            .bind(to: items)
            .disposed(by: disposeBag)
        
        return items.skip(1).asObservable()
    }
}
