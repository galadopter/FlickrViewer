//
//  UIViewController+HUD.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 30.04.21.
//

import Foundation
import PKHUD
import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    
    var isLoading: Binder<Bool> {
        return Binder(base) { _, isLoading in
            isLoading ? HUD.showAppStyleIndicator() : HUD.hide()
        }
    }
    
    func isLoading(onView view: UIView) -> Binder<Bool> {
        return Binder(base) { _, isLoading in
            isLoading ? HUD.showAppStyleIndicator(on: view) : HUD.hide()
        }
    }
    
    func flash(type: HUDContentType, duration: TimeInterval? = nil) -> Binder<Void> {
        return Binder(base) { _, _ in
            if let duration = duration {
                HUD.flash(type, delay: duration)
            } else {
                HUD.flash(type)
            }
        }
    }
}

// MARK: - HUD
private extension HUD {
    
    static func showAppStyleIndicator(on view: UIView? = nil) {
        PKHUD.sharedHUD.contentView = PKHUDRotatingImageView(image: UIImage(named: "loadingIndicator"))
        PKHUD.sharedHUD.effect = nil
        PKHUD.sharedHUD.show(onView: view)
    }
}
