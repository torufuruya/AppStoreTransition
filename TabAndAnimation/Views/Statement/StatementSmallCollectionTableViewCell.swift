//
//  StatementSmallCollectionTableViewCell.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/23.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

class StatementSmallCollectionTableViewCell: UITableViewCell, CardTableViewCell {

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

    private var transition: SmallStatementCardTransition?

    private var cardLayout: UICollectionViewFlowLayout? {
        return self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    private let cardLayoutInset = UIEdgeInsets(top: 0, left: 32.0, bottom: 0, right: 32.0)

    override func awakeFromNib() {
        super.awakeFromNib()

        self.collectionView.delaysContentTouches = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.clipsToBounds = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.register(UINib(nibName: "\(StatementCardCollectionViewCell.self)", bundle: nil), forCellWithReuseIdentifier: "Cell")

        self.cardLayout?.scrollDirection = .horizontal
        self.cardLayout?.sectionInset = self.cardLayoutInset
        self.cardLayout?.minimumLineSpacing = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension StatementSmallCollectionTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! StatementCardCollectionViewCell
        let statement = cell.statementContentView
        statement?.viewModel = self._viewModels?[indexPath.row]

        // Hide message
        statement?.messageLabel.isHidden = true
        statement?.messageLabelToMonthLabel.constant = 0
        statement?.priceLabelToMessageLabel.constant = 0

        // Hide dueDate label
        statement?.dueDateLabel.isHidden = true

        // Fix font
        statement?.monthLabel.font = .systemFont(ofSize: 16, weight: .bold)
        statement?.priceLabel.font = .systemFont(ofSize: 16, weight: .bold)

        // NOTE: Don't hide dueDateLabel and payButton explicitly.
        // They are supposed to be hidden by cell's clipToBounds=true.
        // It enables us to show them in the detail view w/o doing anything.

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let lineSpacing: CGFloat = 15
        let cardHorizontalOffset = self.cardLayoutInset.left
        let numberOfVisibleCell: CGFloat = 2

        let width = (collectionView.bounds.width - lineSpacing - cardHorizontalOffset * 2) / numberOfVisibleCell
        let height: CGFloat = 176
        return .init(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! StatementCardCollectionViewCell
        cell.statementContentView.viewModel = self._viewModels?[indexPath.row]
    }
}

extension StatementSmallCollectionTableViewCell: UICollectionViewDelegateFlowLayout {

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

        let params = SmallStatementCardTransition.Params(
            fromCardFrame: cardPresentationFrameOnScreen,
            fromCardFrameWithoutTransform: cardFrameWithoutTransform,
            fromCell: cell)
        self.transition = SmallStatementCardTransition(params: params)
        detail.transitioningDelegate = self.transition

        // If `modalPresentationStyle` is not `.fullScreen`, this should be set to true to make status bar depends on presented vc.
        detail.modalPresentationCapturesStatusBarAppearance = true
        detail.modalPresentationStyle = .custom

        detail.viewModel = self._viewModels?[indexPath.row]

        self.viewController?.present(detail, animated: true)
    }
}
