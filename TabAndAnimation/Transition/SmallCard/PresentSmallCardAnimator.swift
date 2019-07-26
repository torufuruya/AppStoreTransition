//
//  PresentSmallCardAnimator.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/18.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

final class PresentSmallCardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let params: Params

    struct Params {
        let fromCardFrame: CGRect
        let fromCell: CardCollectionViewCell
    }

    private let presentAnimationDuration: TimeInterval
    private let springAnimator: UIViewPropertyAnimator
    private var transitionDriver: PresentSmallCardTransitionDriver?

    init(params: Params) {
        self.params = params
        self.springAnimator = PresentSmallCardAnimator.createBaseSpringAnimator(params: params)
        self.presentAnimationDuration = springAnimator.duration
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.presentAnimationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionDriver = PresentSmallCardTransitionDriver(
            params: params,
            transitionContext: transitionContext,
            baseAnimator: springAnimator)
        self.transitionDriver?.animator.startAnimation()
    }

    private static func createBaseSpringAnimator(params: PresentSmallCardAnimator.Params) -> UIViewPropertyAnimator {
        // Damping between 0.7 (far away) and 1.0 (nearer)
        let cardPositionY = params.fromCardFrame.minY
        let distanceToBounce = abs(params.fromCardFrame.minY)
        let extentToBounce = cardPositionY < 0 ? params.fromCardFrame.height : UIScreen.main.bounds.height
        let dampFactorInterval: CGFloat = 0.3
        let damping: CGFloat = 1.0 - dampFactorInterval * (distanceToBounce / extentToBounce)

        // Duration between 0.5 (nearer) and 0.9 (far away)
        let baselineDuration: TimeInterval = 0.5
        let maxDuration: TimeInterval = 0.9
        let duration: TimeInterval = baselineDuration + (maxDuration - baselineDuration) * TimeInterval(max(0, distanceToBounce)/UIScreen.main.bounds.height)

        let springTiming = UISpringTimingParameters(dampingRatio: damping, initialVelocity: .init(dx: 0, dy: 0))
        return UIViewPropertyAnimator(duration: duration, timingParameters: springTiming)
    }
}

final class PresentSmallCardTransitionDriver {
    let animator: UIViewPropertyAnimator
    init(params: PresentSmallCardAnimator.Params, transitionContext: UIViewControllerContextTransitioning, baseAnimator: UIViewPropertyAnimator) {
        let ctx = transitionContext
        let container = ctx.containerView
        let screens: (home: UITabBarController, detail: DetailViewController) = (
            ctx.viewController(forKey: .from)! as! UITabBarController,
            ctx.viewController(forKey: .to)! as! DetailViewController
        )

        let detailView = ctx.view(forKey: .to)!
        let fromCardFrame = params.fromCardFrame

        // -------------------------------
        // Temporary container view preparation
        // -------------------------------
        let animatedContainerView = UIView()
        animatedContainerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(animatedContainerView)

        // Fix centerX/width/height of animated container to container.
        NSLayoutConstraint.activate([
            animatedContainerView.widthAnchor.constraint(equalToConstant: container.bounds.width),
            animatedContainerView.heightAnchor.constraint(equalToConstant: container.bounds.height),
            animatedContainerView.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])

        let animatedContainerVerticalConstraint: NSLayoutConstraint = {
            return animatedContainerView.topAnchor.constraint(equalTo: container.topAnchor, constant: fromCardFrame.minY)
        }()
        animatedContainerVerticalConstraint.isActive = true

        animatedContainerView.addSubview(detailView)
        detailView.translatesAutoresizingMaskIntoConstraints = false

        // -------------------------------
        // Destination preparation
        // -------------------------------
        do /* Pin top (or center Y) and center X of the card, in animated container view */ {
            let verticalAnchor: NSLayoutConstraint = {
                // WTF: SUPER WEIRD BUG HERE.
                // I should set this constant to 0 (or nil), to make cardDetailView sticks to the animatedContainerView's top.
                // BUT, I can't set constant to 0, or any value in range (-1,1) here, or there will be abrupt top space inset while animating.
                // Funny how -1 and 1 work! WTF. You can try set it to 0.
                return detailView.topAnchor.constraint(equalTo: animatedContainerView.topAnchor, constant: -1)
            }()
            let cardConstraints = [
                verticalAnchor,
//                detailView.centerXAnchor.constraint(equalTo: animatedContainerView.centerXAnchor),
            ]
            NSLayoutConstraint.activate(cardConstraints)
        }
        // Shrink the detail view size to the size of Card.
        let detailViewWidthConstraint = detailView.widthAnchor.constraint(equalToConstant: fromCardFrame.width)
        let detailViewHeightConstraint = detailView.heightAnchor.constraint(equalToConstant: fromCardFrame.height)
        let detailViewLeadingConstraint = detailView.leadingAnchor.constraint(equalTo: animatedContainerView.leadingAnchor, constant: fromCardFrame.minX)
        NSLayoutConstraint.activate([detailViewWidthConstraint, detailViewHeightConstraint, detailViewLeadingConstraint])

        detailView.layer.cornerRadius = 16.0

        // -------------------------------
        // Final preparation
        // -------------------------------
        params.fromCell.isHidden = true
        params.fromCell.resetTransform()

        let cardContentView = screens.detail.cardContentView!

        let topTemporaryFix = cardContentView.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 0)
        topTemporaryFix.isActive = true

        // Stretch statement content view to fill the small card.
        let stretchCardToFillBottom = cardContentView.bottomAnchor.constraint(equalTo: detailView.bottomAnchor)
        stretchCardToFillBottom.isActive = true

        container.layoutIfNeeded()

        // ------------------------------
        // 1. Animate container bouncing up
        // ------------------------------
        func animateContainerBouncingUp() {
            animatedContainerVerticalConstraint.constant = 0
            container.layoutIfNeeded()
        }

        // ------------------------------
        // 2. Animate cardDetail filling up the container
        // ------------------------------
        func animateCardDetailViewSizing() {
            detailViewWidthConstraint.constant = animatedContainerView.bounds.width
            detailViewHeightConstraint.constant = animatedContainerView.bounds.height
            detailViewLeadingConstraint.constant = 0
            detailView.layer.cornerRadius = 0
            detailView.clipsToBounds = true
            container.layoutIfNeeded()
        }

        func completeEverything() {
            // Remove temporary `animatedContainerView`
            animatedContainerView.removeConstraints(animatedContainerView.constraints)
            animatedContainerView.removeFromSuperview()

            // Re-add to the top
            container.addSubview(detailView)

            detailView.removeConstraints([topTemporaryFix, detailViewWidthConstraint, detailViewHeightConstraint])

            // Keep -1 to be consistent with the weird bug above.
            detailView.edges(to: container, top: -1)

            // No longer need the bottom constraint that pins bottom of card content to its root.
            //            screens.cardDetail.cardBottomToRootBottomConstraint.isActive = false
//            screens.detail.scrollView.isScrollEnabled = true

            let success = !ctx.transitionWasCancelled
            ctx.completeTransition(success)
        }

        baseAnimator.addAnimations {
            // Remove stretchCardToFillBottom constraints immediately.
            stretchCardToFillBottom.isActive = false

            animateContainerBouncingUp()

            let cardExpanding = UIViewPropertyAnimator(duration: baseAnimator.duration * 0.7, curve: .linear) {
                animateCardDetailViewSizing()
            }
            cardExpanding.startAnimation()
        }

        baseAnimator.addCompletion { _ in
            completeEverything()
        }

        self.animator = baseAnimator
    }
}
