//
//  StatementCollectionTableViewCell.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/23.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

class StatementCollectionTableViewCell: UITableViewCell, CardTableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!

    weak var viewController: UIViewController?

    var viewModels: [ViewModel] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    private var _viewModels: [StatementViewModel]? {
        return self.viewModels as? [StatementViewModel]
    }

    private var transition: StatementCardTransition?

    private let cardLayout = CardCollectionViewFlowLayout()
    private let cardLayoutInset = UIEdgeInsets(top: 0, left: 32.0, bottom: 0, right: 32.0)

    override func awakeFromNib() {
        super.awakeFromNib()

        self.collectionView.delaysContentTouches = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.clipsToBounds = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.register(UINib(nibName: "\(StatementCardCollectionViewCell.self)", bundle: nil), forCellWithReuseIdentifier: "Cell")

        self.cardLayout.scrollDirection = .horizontal
        self.cardLayout.sectionInset = self.cardLayoutInset
        self.collectionView.collectionViewLayout = self.cardLayout
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension StatementCollectionTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! StatementCardCollectionViewCell
        let statementView = cell.statementContentView!
        let viewModel = self._viewModels?[indexPath.row]
        statementView.viewModel = viewModel

        // Hide icon
        statementView.iconImageView.isHidden = true
        statementView.iconHeight.constant = 0

        if viewModel?.status == .overdue {
            statementView.messageLabel.isHidden = false
            statementView.payButton.backgroundColor = .red
            let messageHeight: CGFloat = statementView.messageLabel.bounds.height
            statementView.iconToTop.constant -= messageHeight
        } else {
            // Shrink the needless spaces
            statementView.monthLabelToIcon.constant = 0
            statementView.priceLabelToMessageLabel.constant = 0
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cardHorizontalOffset = self.cardLayoutInset.left
        let width = collectionView.bounds.width - CGFloat(2 * cardHorizontalOffset)
        let height: CGFloat = 280
        let size = CGSize(width: width, height: height)
        self.cardLayout.itemSize = size
        return size
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! StatementCardCollectionViewCell
        cell.statementContentView.viewModel = self._viewModels?[indexPath.row]
    }
}

extension StatementCollectionTableViewCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detail = StatementDetailViewController()

        // Get tapped cell location
        let cell = collectionView.cellForItem(at: indexPath) as! StatementCardCollectionViewCell
        // Get current frame on screen
        let currentCellFrame = cell.layer.presentation()!.frame
        // Convert current frame to screen's coordinates
        let cardPresentationFrameOnScreen = cell.superview!.convert(currentCellFrame, to: nil)
        // Get card frame without transform in screen's coordinates  (for the dismissing back later to original location)
        let cardFrameWithoutTransform = { () -> CGRect in
            let center = cell.center
            let size = cell.bounds.size
            let r = CGRect(
                x: center.x - size.width / 2,
                y: center.y - size.height / 2,
                width: size.width,
                height: size.height
            )
            return cell.superview!.convert(r, to: nil)
        }()

        let params = StatementCardTransition.Params(
            fromCardFrame: cardPresentationFrameOnScreen,
            fromCardFrameWithoutTransform: cardFrameWithoutTransform,
            fromCell: cell)
        self.transition = StatementCardTransition(params: params)
        detail.transitioningDelegate = self.transition

        // If `modalPresentationStyle` is not `.fullScreen`, this should be set to true to make status bar depends on presented vc.
        detail.modalPresentationCapturesStatusBarAppearance = true
        detail.modalPresentationStyle = .custom

        detail.viewModel = self._viewModels?[indexPath.row]

        self.viewController?.present(detail, animated: true)
    }
}
