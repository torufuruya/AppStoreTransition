//
//  SmallCardCollectionTableViewCell.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/23.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

class SmallCardCollectionTableViewCell: UITableViewCell, CardTableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!

    weak var viewController: UIViewController?

    var viewModels: [ViewModel] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    private var _viewModels: [CardContentViewModel]? {
        return self.viewModels as? [CardContentViewModel]
    }

    private var transition: SmallCardTransition?

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
        self.collectionView.register(UINib(nibName: "\(CardCollectionViewCell.self)", bundle: nil), forCellWithReuseIdentifier: "CardCollectionViewCell")

        self.cardLayout?.scrollDirection = .horizontal
        self.cardLayout?.sectionInset = self.cardLayoutInset
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension SmallCardCollectionTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as! CardCollectionViewCell
        cell.cardContentView.viewModel = self._viewModels?[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 176, height: 176)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as! CardCollectionViewCell
        cell.cardContentView.viewModel = self._viewModels?[indexPath.row]
    }
}

extension SmallCardCollectionTableViewCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detail = DetailViewController()

        // Get tapped cell location
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
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

        // Calculate height for animation container which does not include tab bar height
        // otherwise UI component can be displayed over tab bar during animation.
        let tabBarHeight: CGFloat = self.viewController?.tabBarController?.tabBar.frame.height ?? 0
        var containerFrame = self.viewController?.view.bounds ?? .zero
        containerFrame.size.height = max(0, containerFrame.height - tabBarHeight)

        let params = SmallCardTransition.Params(
            fromCardFrame: cardPresentationFrameOnScreen,
            fromCardFrameWithoutTransform: cardFrameWithoutTransform,
            fromCell: cell,
            tabBar: self.viewController?.tabBarController?.tabBar)
        self.transition = SmallCardTransition(params: params)
        detail.transitioningDelegate = self.transition

        // If `modalPresentationStyle` is not `.fullScreen`, this should be set to true to make status bar depends on presented vc.
        detail.modalPresentationCapturesStatusBarAppearance = true
        detail.modalPresentationStyle = .custom

        detail.viewModel = self._viewModels?[indexPath.row]

        self.viewController?.present(detail, animated: true)
    }
}
