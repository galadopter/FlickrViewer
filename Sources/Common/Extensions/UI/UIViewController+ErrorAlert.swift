//
//  UIViewController+ErrorAlert.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 30.04.21.
//

import UIKit
import RxCocoa
import RxSwift

extension UIViewController {
    
    func show(error: Error) {
        let message = (error as? AppError)?.message ?? error.localizedDescription
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension Reactive where Base: UIViewController {
    
    var error: Binder<Error> {
        return Binder(self.base) { viewController, error in
            viewController.show(error: error)
        }
    }
}
