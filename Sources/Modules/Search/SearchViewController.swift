//
//  SearchViewController.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 28.04.21.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var searchBar: UISearchBar!
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, SearchedImageCellViewModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SearchedImageCellViewModel>
    
    enum Section: String, Hashable, Equatable {
        case images
    }
    
    private lazy var dataSource: DataSource = makeDataSource()
    
    private let viewModel = SearchViewModel()
    private let bag = DisposeBag()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

//MARK: - Setup
private extension SearchViewController {
    
    func setup() {
        collectionView.register(SearchedImageCell.self, forCellWithReuseIdentifier: SearchedImageCell.reuseIdentifier)
        collectionView.collectionViewLayout = makeLayout()
        bind()
    }
}

// MARK: - Binding
private extension SearchViewController {
    
    var input: SearchViewModel.Input {
        .init(
            text: searchBar.rx.text.orEmpty.asDriver(),
            loadNextPage: nextPage()
        )
    }
    
    func bind() {
        let output = viewModel.transform(input: input)
        
        bag.insert {
            output.errors.emit(to: rx.error)
            output.isLoading.drive(rx.isLoading(onView: view))
            output.photos.drive(onNext: { [weak self] viewModels in
                var snapshot = Snapshot()
                if viewModels.isEmpty {
                    snapshot.deleteSections([.images])
                    snapshot.deleteAllItems()
                } else {
                    if snapshot.sectionIdentifiers.isEmpty {
                        snapshot.appendSections([.images])
                    }
                    snapshot.appendItems(viewModels, toSection: .images)
                }
                DispatchQueue.main.async {
                    self?.dataSource.apply(snapshot)
                }
            })
        }
    }
    
    func nextPage() -> Driver<Void> {
        return collectionView.rx.willEndDragging
            .map { [unowned self] _, target -> CGFloat in
                return self.collectionView.contentSize.height - (target.pointee.y + self.collectionView.bounds.height) }
            .filter { $0 < 100 }.map { _ in }
            .asDriver(onErrorJustReturn: ())
    }
}

// MARK: - Layout
private extension SearchViewController {
    
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let cellSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 2), heightDimension: .absolute(145))
        let item = NSCollectionLayoutItem(layoutSize: cellSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(145))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(15)
        
        
        let section = NSCollectionLayoutSection(group: group)
        
        return .init(section: section)
    }
}

// MARK: - Data Source
private extension SearchViewController {
    
    private func makeDataSource() -> DataSource {
        .init(collectionView: collectionView) { collectionView, indexPath, viewModel in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchedImageCell.reuseIdentifier, for: indexPath) as? SearchedImageCell else { return nil }
            cell.configure(with: viewModel)
            return cell
        }
    }
}
