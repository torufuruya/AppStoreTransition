//
//  SmallStatementCardPresentAnimator.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/24.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

final class SmallStatementCardPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    struct Params {
        let fromFrame: CGRect
        let fromCell: StatementCardCollectionViewCell
    }

    let params: Params

    init(params: Params) {
        self.params = params
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let ctx = transitionContext
        let container = ctx.containerView
        let fromFrame = self.params.fromFrame

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
        // Final preparation
        // -------------------------------
        self.params.fromCell.resetTransform()
        self.params.fromCell.isHidden = true
        let presentedViewController = ctx.viewController(forKey: .to)! as! StatementDetailViewController
        let statementContentView = presentedViewController.statementContentView!

        // Temporarily hide the upper area of presented view (restore it in animation)
        let temporaryPresentedViewTopConstraint = statementContentView.topAnchor.constraint(equalTo: presentedView.topAnchor, constant: 0)
        temporaryPresentedViewTopConstraint.isActive = true

        // Hide message
        statementContentView.messageLabel.alpha = 0.0
        statementContentView.messageLabelToMonthLabel.constant = 0
        statementContentView.priceLabelToMessageLabel.constant = 0

        statementContentView.shrinkPriceLabel()

        // Hide dismiss button
        presentedViewController.dismissButton.alpha = 0.0

        // Stretch statement content view to fill the small card.
        let stretchCardToFillBottom = presentedViewController.statementContentView.bottomAnchor.constraint(equalTo: presentedView.bottomAnchor)
        stretchCardToFillBottom.isActive = true

        container.layoutIfNeeded()

        // -------------------------------
        // Execute animation
        // -------------------------------
        UIView.animate(withDuration: self.transitionDuration(using: ctx), delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            // Remove stretchCardToFillBottom constraints immediately.
            stretchCardToFillBottom.isActive = false

            // Bounce up animated container.
            do {
                animatedContainerVerticalConstraint.constant = 0
                container.layoutIfNeeded()
            }
            // Update presented view size to fill up the container.
            do {
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
            // Update the appearance depends on the content.
            // For example, show pay button if the content is payable.
            do {
                // Hide icon
                statementContentView.iconImageView.alpha = 0.0
                // Hide month
                statementContentView.monthLabel.alpha = 0.0

                // Show message
                statementContentView.messageLabel.alpha = 1.0
                statementContentView.messageLabelToMonthLabel.constant = 8
                statementContentView.priceLabelToMessageLabel.constant = 8

                statementContentView.priceLabel.transform = .identity

                // Show dismiss button
                presentedViewController.dismissButton.alpha = 1.0

                container.layoutIfNeeded()
            }
        }, completion: { finished in
            // Remove temporary container
            animatedContainerView.removeConstraints(animatedContainerView.constraints)
            animatedContainerView.removeFromSuperview()
            // Re-add the destination view to the top
            container.addSubview(presentedView)
            presentedView.edges(to: container, top: -1)
            ctx.completeTransition(finished)
        })
    }
}
