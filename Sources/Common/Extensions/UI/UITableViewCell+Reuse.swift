//
//  UITableViewCell+Reuse.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 30.04.21.
//

import UIKit

public extension UITableViewCell {
    
    static var reuseIdentifier: String {
        String(describing: self)
    }

    static var nib: UINib {
        UINib(nibName: reuseIdentifier, bundle: Bundle(for: self))
    }
}

public extension UICollectionViewCell {
    
    static var reuseIdentifier: String {
        String(describing: self)
    }

    static var nib: UINib {
        UINib(nibName: reuseIdentifier, bundle: Bundle(for: self))
    }
}
