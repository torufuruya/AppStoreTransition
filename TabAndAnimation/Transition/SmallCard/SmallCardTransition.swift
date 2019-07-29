//
//  SmallCardTransition.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/18.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

final class SmallCardTransition: NSObject, UIViewControllerTransitioningDelegate {
    struct Params {
        let fromCardFrame: CGRect
        let fromCardFrameWithoutTransform: CGRect
        let fromCell: CardCollectionViewCell
        let tabBar: UITabBar?
    }

    let params: Params

    init(params: Params) {
        self.params = params
        super.init()
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let params = PresentSmallCardAnimator.Params.init(
            fromCardFrame: self.params.fromCardFrame,
            fromCell: self.params.fromCell,
            tabBar: self.params.tabBar
        )
        return PresentSmallCardAnimator(params: params)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let params = DismissSmallCardAnimator.Params.init(
            fromCardFrame: self.params.fromCardFrame,
            fromCardFrameWithoutTransform: self.params.fromCardFrameWithoutTransform,
            fromCell: self.params.fromCell,
            tabBar: self.params.tabBar
        )
        return DismissSmallCardAnimator(params: params)
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SmallCardPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
