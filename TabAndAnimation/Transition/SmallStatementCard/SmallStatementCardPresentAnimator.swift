//
//  SmallStatementCardPresentAnimator.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/24.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

final class SmallStatementCardPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let params: PresentStatementCardAnimator.Params

    private let presentAnimationDuration: TimeInterval
    private let springAnimator: UIViewPropertyAnimator

    init(params: PresentStatementCardAnimator.Params) {
        self.params = params
        self.springAnimator = SmallStatementCardPresentAnimator.createBaseSpringAnimator(params: params)
        self.presentAnimationDuration = self.springAnimator.duration
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.presentAnimationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let ctx = transitionContext
        let container = ctx.containerView
        let fromFrame = self.params.fromCardFrame

        // -------------------------------
        // Temporary container preparation
        // -------------------------------
        let animatedContainerView = UIView()
        animatedContainerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(animatedContainerView)

        NSLayoutConstraint.activate([
            animatedContainerView.widthAnchor.constraint(equalToConstant: container.bounds.width),
            animatedContainerView.heightAnchor.constraint(equalToConstant: container.bounds.height),
            animatedContainerView.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])

        let animatedContainerVerticalConstraint = animatedContainerView.topAnchor.constraint(equalTo: container.topAnchor, constant: fromFrame.minY)
        animatedContainerVerticalConstraint.isActive = true

        // -------------------------------
        // Destination preparation
        // -------------------------------
        let presentedView = ctx.view(forKey: .to)!
        presentedView.translatesAutoresizingMaskIntoConstraints = false
        presentedView.layer.cornerRadius = 16.0
        animatedContainerView.addSubview(presentedView)

        // WTF: SUPER WEIRD BUG HERE.
        // I should set this constant to 0 (or nil), to make cardDetailView sticks to the animatedContainerView's top.
        // BUT, I can't set constant to 0, or any value in range (-1,1) here, or there will be abrupt top space inset while animating.
        // Funny how -1 and 1 work! WTF. You can try set it to 0.
        let presentedViewVerticalConstraint = presentedView.topAnchor.constraint(equalTo: animatedContainerView.topAnchor, constant: -1)

        let presentedViewWidthConstraint = presentedView.widthAnchor.constraint(equalToConstant: fromFrame.width)
        let presentedViewHeightConstraint = presentedView.heightAnchor.constraint(equalToConstant: fromFrame.height)
        let presentedViewLeadingConstraint = presentedView.leadingAnchor.constraint(equalTo: animatedContainerView.leadingAnchor, constant: fromFrame.minX)
        NSLayoutConstraint.activate([
            presentedViewVerticalConstraint,
            presentedViewWidthConstraint,
            presentedViewHeightConstraint,
            presentedViewLeadingConstraint
        ])

        // -------------------------------
        // Statement content view preparation
        // -------------------------------
        let presentedViewController = ctx.viewController(forKey: .to)! as! StatementDetailViewController
        let statement = presentedViewController.viewModel!
        let statementContentView = presentedViewController.statementContentView!

        if statement.status == .overdue {
            // Display overdue information
            statementContentView.backgroundColor = .red
            statementContentView.iconImageView.image = #imageLiteral(resourceName: "ic_overdue")
            statementContentView.iconImageView.tintColor = .white
            statementContentView.monthLabel.textColor = .white
            statementContentView.priceLabel.textColor = .white
            statementContentView.payButton.backgroundColor = .red
        }

        // Hide message
        statementContentView.messageLabel.isHidden = false
        statementContentView.messageLabel.alpha = 0.0
        statementContentView.messageLabelToMonthLabel.constant = 0
        statementContentView.priceLabelToMessageLabel.constant = 0

        // Make month font weight regular unless overdue
        if statement.status != .overdue {
            statementContentView.makeMonthFontRegular()
        }

        // Shrink price label (larger in detail screen)
        statementContentView.shrinkPriceLabel()

        // Hide dismiss button
        presentedViewController.dismissButton.alpha = 0.0

        // -------------------------------
        // Final preparation
        // -------------------------------
        self.params.fromCell.resetTransform()
        self.params.fromCell.isHidden = true

        // Temporarily hide the upper area of presented view (restore it in animation)
        let temporaryPresentedViewTopConstraint = statementContentView.topAnchor.constraint(equalTo: presentedView.topAnchor, constant: 0)
        temporaryPresentedViewTopConstraint.isActive = true

        // Stretch statement content view to fill the small card.
        let stretchCardToFillBottom = presentedViewController.statementContentView.bottomAnchor.constraint(equalTo: presentedView.bottomAnchor)
        stretchCardToFillBottom.isActive = true

        container.layoutIfNeeded()

        // -------------------------------
        // Execute animation
        // -------------------------------
        func animateContainerBouncingUp() {
            animatedContainerVerticalConstraint.constant = 0
            container.layoutIfNeeded()
        }

        func animateStatementAppearance() {
            // Hide icon
            statementContentView.iconImageView.alpha = 0.0
            // Hide month
            statementContentView.monthLabel.alpha = 0.0
            // Restore the size of price label
            statementContentView.priceLabel.transform = .identity
            // Show dismiss button
            presentedViewController.dismissButton.alpha = 1.0

            if statement.status == .overdue {
                // Show message
                statementContentView.messageLabel.alpha = 1.0
                statementContentView.messageLabelToMonthLabel.constant = 8
                statementContentView.priceLabelToMessageLabel.constant = 8
                // Restore the text color of price.
                statementContentView.priceLabel.textColor = .black
                // Update background color red -> white.
                statementContentView.backgroundColor = .white
            }
            container.layoutIfNeeded()
        }

        func animateCardDetailViewSizing() {
            presentedViewWidthConstraint.constant = animatedContainerView.bounds.width
            presentedViewHeightConstraint.constant = animatedContainerView.bounds.height
            presentedViewLeadingConstraint.constant = 0

            presentedView.layer.cornerRadius = 0
            presentedView.clipsToBounds = true
            // Expand the top area to restore the appearance.
            // `presentedViewController.headerImageView.bounds.height` instead of 100 works in iPhone XR but not in iPhone XS ;(
            temporaryPresentedViewTopConstraint.constant = 100
            container.layoutIfNeeded()
        }

        func completeEverything() {
            // Remove temporary container
            animatedContainerView.removeConstraints(animatedContainerView.constraints)
            animatedContainerView.removeFromSuperview()
            // Re-add the destination view to the top
            container.addSubview(presentedView)
            presentedView.edges(to: container, top: -1)
            let success = !ctx.transitionWasCancelled
            ctx.completeTransition(success)
        }

        self.springAnimator.addAnimations {
            // Remove stretchCardToFillBottom constraints immediately.
            stretchCardToFillBottom.isActive = false
            // Bounce up animated container.
            animateContainerBouncingUp()
            // Update the appearance depends on the content.
            // For example, show pay button if the content is payable.
            animateStatementAppearance()

            // Update presented view size to fill up the container.
            let cardExpanding = UIViewPropertyAnimator(duration: self.springAnimator.duration * 0.7, curve: .linear) {
                animateCardDetailViewSizing()
            }
            cardExpanding.startAnimation()
        }
        self.springAnimator.addCompletion { position in
            completeEverything()
        }
        self.springAnimator.startAnimation()
    }

    private static func createBaseSpringAnimator(params: PresentStatementCardAnimator.Params) -> UIViewPropertyAnimator {
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
