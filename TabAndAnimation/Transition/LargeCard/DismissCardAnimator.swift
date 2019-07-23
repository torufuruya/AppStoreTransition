//
//  DismissCardAnimator.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/18.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

final class DismissCardAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    struct Params {
        let fromCardFrame: CGRect
        let fromCardFrameWithoutTransform: CGRect
        let fromCell: CardCollectionViewCell
    }

    struct Constants {
        static let relativeDurationBeforeNonInteractive: TimeInterval = 0.5
        static let minimumScaleBeforeNonInteractive: CGFloat = 0.8
    }

    private let params: Params

    init(params: Params) {
        self.params = params
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let ctx = transitionContext
        let container = ctx.containerView
        let screens: (detail: DetailViewController, home: UITabBarController) = (
            ctx.viewController(forKey: .from)! as! DetailViewController,
            ctx.viewController(forKey: .to)! as! UITabBarController
        )

        let detailView = ctx.view(forKey: .from)!

        // -------------------------------
        // Temporary container view preparation
        // -------------------------------
        let animatedContainerView = UIView()
        animatedContainerView.translatesAutoresizingMaskIntoConstraints = false
        detailView.translatesAutoresizingMaskIntoConstraints = false

        container.removeConstraints(container.constraints)

        container.addSubview(animatedContainerView)
        animatedContainerView.addSubview(detailView)

        // Card fills inside animated container view
        detailView.edges(to: animatedContainerView)

        animatedContainerView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        let animatedContainerTopConstraint = animatedContainerView.topAnchor.constraint(equalTo: container.topAnchor, constant: 0)
        let animatedContainerWidthConstraint = animatedContainerView.widthAnchor.constraint(equalToConstant: detailView.frame.width)
        let animatedContainerHeightConstraint = animatedContainerView.heightAnchor.constraint(equalToConstant: detailView.frame.height)

        NSLayoutConstraint.activate([animatedContainerTopConstraint, animatedContainerWidthConstraint, animatedContainerHeightConstraint])

        // Fix weird top inset
        let topTemporaryFix = screens.detail.cardContentView.topAnchor.constraint(equalTo: detailView.topAnchor)
        topTemporaryFix.isActive = true

        container.layoutIfNeeded()

        // Force card filling bottom
        let stretchCardToFillBottom = screens.detail.cardContentView.bottomAnchor.constraint(equalTo: detailView.bottomAnchor)

        func animateCardViewBackToPlace() {
            stretchCardToFillBottom.isActive = true
            // Back to identity
            // NOTE: Animated container view in a way, helps us to not messing up `transform` with `AutoLayout` animation.
            detailView.transform = .identity
            animatedContainerTopConstraint.constant = self.params.fromCardFrameWithoutTransform.minY
            animatedContainerWidthConstraint.constant = self.params.fromCardFrameWithoutTransform.width
            animatedContainerHeightConstraint.constant = self.params.fromCardFrameWithoutTransform.height

            detailView.layer.cornerRadius = 16.0
            detailView.clipsToBounds = true
            screens.detail.dismissButton.alpha = 0.0

            container.layoutIfNeeded()
        }

        func completeEverything() {
            let success = !ctx.transitionWasCancelled
            animatedContainerView.removeConstraints(animatedContainerView.constraints)
            animatedContainerView.removeFromSuperview()
            if success {
                detailView.removeFromSuperview()
                self.params.fromCell.isHidden = false
            } else {
                // Remove temporary fixes if not success!
                topTemporaryFix.isActive = false
                stretchCardToFillBottom.isActive = false

                detailView.removeConstraint(topTemporaryFix)
                detailView.removeConstraint(stretchCardToFillBottom)

                container.removeConstraints(container.constraints)

                container.addSubview(detailView)
                detailView.edges(to: container)
            }
            ctx.completeTransition(success)
        }

        UIView.animate(withDuration: transitionDuration(using: ctx), delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            animateCardViewBackToPlace()
        }) { (finished) in
            completeEverything()
        }

        UIView.animate(withDuration: transitionDuration(using: ctx) * 0.6) {
//            screens.detail.scrollView.contentOffset = .zero
        }
    }
}
