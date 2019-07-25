//
//  SmallStatementCardTransition.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/24.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

final class SmallStatementCardTransition: NSObject, UIViewControllerTransitioningDelegate {

    struct Params {
        let fromCardFrame: CGRect
        let fromCardFrameWithoutTransform: CGRect
        let fromCell: StatementCardCollectionViewCell
    }

    let params: Params

    init(params: Params) {
        self.params = params
        super.init()
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SmallStatementCardPresentAnimator(params: PresentStatementCardAnimator.Params(
            fromCardFrame: self.params.fromCardFrame,
            fromCell: self.params.fromCell))
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SmallStatementCardDismissAnimator(params: SmallStatementCardDismissAnimator.Params(
            fromFrame: self.params.fromCardFrame,
            fromFrameWithoutTransform: self.params.fromCardFrameWithoutTransform,
            fromCell: self.params.fromCell))
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return StatementCardPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
