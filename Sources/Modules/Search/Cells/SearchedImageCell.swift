//
//  SearchedImageCell.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 28.04.21.
//

import UIKit
import Nuke

struct SearchedImageCellViewModel: Hashable, Equatable {
    let imageURL: URL
    let title: String
}

class SearchedImageCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    func configure(with viewModel: SearchedImageCellViewModel) {
        Nuke.loadImage(with: viewModel.imageURL, into: imageView)
        titleLabel.text = viewModel.title
    }
}

//MARK: - Setup
private extension SearchedImageCell {
    
    func setup() {
        addSubview(imageView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 4),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 4),
            bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
        ])
    }
}
