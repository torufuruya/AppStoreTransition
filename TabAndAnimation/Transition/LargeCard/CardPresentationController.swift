//
//  CardPresentationController.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/19.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

class CardPresentationController: UIPresentationController {

    private lazy var blurView = UIVisualEffectView(effect: nil)

    override func presentationTransitionWillBegin() {
        let container = containerView!
        blurView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(blurView)
        // Use fixed width and height constraint because
        // constraints to container will be removed in DismissCardAnimator.
//        blurView.edges(to: container)
        NSLayoutConstraint.activate([
            blurView.widthAnchor.constraint(equalToConstant: container.bounds.width),
            blurView.heightAnchor.constraint(equalToConstant: container.bounds.height)
        ])
        blurView.alpha = 0.0

        presentingViewController.beginAppearanceTransition(false, animated: false)
        presentedViewController.transitionCoordinator!.animate(alongsideTransition: { (ctx) in
            UIView.animate(withDuration: 0.5, animations: {
                self.blurView.effect = UIBlurEffect(style: .dark)
                self.blurView.alpha = 1
            })
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        presentingViewController.endAppearanceTransition()
    }

    override func dismissalTransitionWillBegin() {
        presentingViewController.beginAppearanceTransition(true, animated: true)
        presentedViewController.transitionCoordinator!.animate(alongsideTransition: { (ctx) in
            self.blurView.alpha = 0.0
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        presentingViewController.endAppearanceTransition()
        if completed {
            blurView.removeFromSuperview()
        }
    }
}
