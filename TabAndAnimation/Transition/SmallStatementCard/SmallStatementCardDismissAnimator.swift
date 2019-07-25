//
//  SmallStatementCardDismissAnimator.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/24.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

final class SmallStatementCardDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    struct Params {
        let fromFrame: CGRect
        let fromFrameWithoutTransform: CGRect
        let fromCell: StatementCardCollectionViewCell
    }

    let params: Params

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

        container.removeConstraints(container.constraints)
        // -------------------------------
        // Temporary container preparation
        // -------------------------------
        let animatedContainerView = UIView()
        animatedContainerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(animatedContainerView)

        // Drop the same shadow as fromCell
        animatedContainerView.layer.shadowColor = UIColor.black.cgColor
        animatedContainerView.layer.shadowOpacity = 0.2
        animatedContainerView.layer.shadowOffset = .init(width: 0, height: 4)
        animatedContainerView.layer.shadowRadius = 12

        // -------------------------------
        // Destination preparation
        // -------------------------------
        let presentedView = ctx.view(forKey: .from)!
        presentedView.translatesAutoresizingMaskIntoConstraints = false
        animatedContainerView.addSubview(presentedView)
        presentedView.edges(to: animatedContainerView)

        let animatedContainerTopConstraint = animatedContainerView.topAnchor.constraint(equalTo: container.topAnchor, constant: 0)
        let animatedContainerWidthConstraint = animatedContainerView.widthAnchor.constraint(equalToConstant: presentedView.frame.width)
        let animatedContainerHeightConstraint = animatedContainerView.heightAnchor.constraint(equalToConstant: presentedView.frame.height)
        let animatedContainerLeadingConstraint = animatedContainerView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0)

        NSLayoutConstraint.activate([
            animatedContainerTopConstraint,
            animatedContainerWidthConstraint,
            animatedContainerHeightConstraint,
            animatedContainerLeadingConstraint
        ])

        // -------------------------------
        // Final preparation
        // -------------------------------
        let presentedViewController = ctx.viewController(forKey: .from)! as! StatementDetailViewController

        // Temporarily show the upper area of presented view (restore it in animation)
        let temporaryPresentedViewTopConstraint = presentedViewController.statementContentView.topAnchor.constraint(equalTo: presentedView.topAnchor, constant: presentedViewController.headerImageView.bounds.height)
        temporaryPresentedViewTopConstraint.isActive = true

        let stretchCardToFillBottom = presentedViewController.statementContentView.bottomAnchor.constraint(equalTo: presentedView.bottomAnchor)

        container.layoutIfNeeded()

        // -------------------------------
        // Execute animation
        // -------------------------------
        UIView.animate(withDuration: transitionDuration(using: ctx), delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            stretchCardToFillBottom.isActive = true
            // Update animated container size to back to the original place.
            do {
                let fromCardFrameWoT = self.params.fromFrameWithoutTransform
                animatedContainerTopConstraint.constant = fromCardFrameWoT.minY
                animatedContainerWidthConstraint.constant = fromCardFrameWoT.width
                animatedContainerHeightConstraint.constant = fromCardFrameWoT.height
                animatedContainerLeadingConstraint.constant = fromCardFrameWoT.minX

                presentedView.layer.cornerRadius = 16.0
                presentedView.clipsToBounds = true

                // Hide the upper area of presented view.
                temporaryPresentedViewTopConstraint.constant = 0

                container.layoutIfNeeded()
            }
            // Update the appearance depends on the content.
            // For example, show pay button if the content is payable.
            do {
                presentedViewController.dismissButton.alpha = 0.0
                presentedViewController.statementContentView.dueDateLabel.alpha = 0.0

                let statement = presentedViewController.viewModel!
                let statementView = presentedViewController.statementContentView!
                if statement.status == .overdue {
                    statementView.backgroundColor = .red
                    statementView.priceLabel.textColor = .white
                }
                statementView.iconImageView.alpha = 1.0
                statementView.monthLabel.alpha = 1.0
                statementView.messageLabelToMonthLabel.constant = 0
                statementView.priceLabelToMessageLabel.constant = 0

                // Restore the sizes of UI conponents
                statementView.shrinkPriceLabel()
                container.layoutIfNeeded()
            }
        }, completion: { finished in
            let isSuccess = !ctx.transitionWasCancelled
            animatedContainerView.removeConstraints(animatedContainerView.constraints)
            animatedContainerView.removeFromSuperview()
            if isSuccess {
                presentedView.removeFromSuperview()
                self.params.fromCell.isHidden = false
            } else {
                container.addSubview(presentedView)
                presentedView.edges(to: container)
            }
            ctx.completeTransition(finished)
        })
    }
}
