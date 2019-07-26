//
//  StatementDetailViewController.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/23.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

class StatementDetailViewController: StatusBarAnimatableViewController {

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var statementContentView: StatementContentView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dismissButton: UIButton!

    override var statusBarAnimatableConfig: StatusBarAnimatableConfig {
        return .init(prefersHidden: true, animation: .slide)
    }

    var viewModel: StatementViewModel? {
        didSet {
            self.statementContentView?.viewModel = viewModel
        }
    }

    // Properties for Edge pan dismiss animation
    private var dismissalAnimator: UIViewPropertyAnimator?
    private lazy var dismissalScreenEdgePanGesture: UIScreenEdgePanGestureRecognizer = {
        let pan = UIScreenEdgePanGestureRecognizer()
        pan.edges = .left
        return pan
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.statementContentView.viewModel = self.viewModel
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        self.dismissalScreenEdgePanGesture.addTarget(self, action: #selector(handleDismissalPan(gesture:)))
        self.dismissalScreenEdgePanGesture.delegate = self
        self.view.addGestureRecognizer(self.dismissalScreenEdgePanGesture)
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @objc private func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        let targetAnimatedView = gesture.view!
        let currentLocation = gesture.location(in: nil)
        let progress = gesture.translation(in: targetAnimatedView).x / 100
        let targetShrinkScale: CGFloat = 0.86
        let targetCornerRadius: CGFloat = 16

        func createInteractiveDismissalAnimatorIfNeeded() -> UIViewPropertyAnimator {
            if let animator = dismissalAnimator {
                return animator
            } else {
                let animator = UIViewPropertyAnimator(duration: 0, curve: .linear, animations: {
                    targetAnimatedView.transform = .init(scaleX: targetShrinkScale, y: targetShrinkScale)
                    targetAnimatedView.layer.cornerRadius = targetCornerRadius
                })
                animator.isReversed = false
                animator.pauseAnimation()
                animator.fractionComplete = progress
                return animator
            }
        }

        switch gesture.state {
        case .began:
            dismissalAnimator = createInteractiveDismissalAnimatorIfNeeded()
        case .changed:
            dismissalAnimator = createInteractiveDismissalAnimatorIfNeeded()

            let actualProgress = progress
            let isDismissalSuccess = actualProgress >= 1.0

            dismissalAnimator!.fractionComplete = actualProgress

            if isDismissalSuccess {
                dismissalAnimator!.stopAnimation(false)
                dismissalAnimator!.addCompletion { [unowned self] (pos) in
                    switch pos {
                    case .end:
                        self.didSuccessfullyDragDownToDismiss()
                    default:
                        fatalError("Must finish dismissal at end!")
                    }
                }
                dismissalAnimator!.finishAnimation(at: .end)
            }
        case .ended, .cancelled:
            if dismissalAnimator == nil {
                // Gesture's too quick that it doesn't have dismissalAnimator!
                print("Too quick there's no animator!")
                didCancelDismissalTransition()
                return
            }
            // NOTE:
            // If user lift fingers -> ended
            // If gesture.isEnabled -> cancelled

            // Ended, Animate back to start
            dismissalAnimator!.pauseAnimation()
            dismissalAnimator!.isReversed = true

            // Disable gesture until reverse closing animation finishes.
            gesture.isEnabled = false
            dismissalAnimator!.addCompletion { [unowned self] (pos) in
                self.didCancelDismissalTransition()
                gesture.isEnabled = true
            }
            dismissalAnimator!.startAnimation()
        default:
            fatalError("Impossible gesture state? \(gesture.state.rawValue)")
        }
    }

    func didSuccessfullyDragDownToDismiss() {
        dismiss(animated: true)
    }

    private func didCancelDismissalTransition() {
        // Clean up
        dismissalAnimator = nil
    }
}

extension StatementDetailViewController: UITableViewDelegate, UITableViewDataSource {
    var data: [Int] {
        return [1,2,3,4,5,6,7,8,9,10]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Row \(self.data[indexPath.row])"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension StatementDetailViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
