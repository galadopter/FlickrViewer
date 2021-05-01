//
//  Array+Uniqueness.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 1.05.21.
//

import Foundation

public extension Array where Element: Hashable {
    
    mutating func append<S>(contentsOf newElements: S, unique: Bool = false) where S: Sequence, Element == S.Element {
        guard unique else {
            append(contentsOf: newElements)
            return
        }

        newElements.forEach({ append($0, unique: unique) })
    }

    mutating func append(_ newElement: Element, unique: Bool = false) {
        guard unique else {
            self.append(newElement)
            return
        }

        if !contains(newElement) {
            self.append(newElement)
        } else if let index = firstIndex(of: newElement) {
            self[index] = newElement
        }
    }
}
