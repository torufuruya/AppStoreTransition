//
//  FirstViewController.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/18.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

final class SectionHeader: UICollectionReusableView {
    @IBOutlet weak var sectionLabel: UILabel!
}

class FirstViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private var transition: CardTransition?

    private var viewModels = [
        CardContentViewModel(image: #imageLiteral(resourceName: "image1"), primary: "Card 1"),
        CardContentViewModel(image: #imageLiteral(resourceName: "image2"), primary: "Card 2"),
        CardContentViewModel(image: #imageLiteral(resourceName: "image1"), primary: "Card 3")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.delaysContentTouches = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.clipsToBounds = false
        self.collectionView.register(UINib(nibName: "\(CardCollectionViewCell.self)", bundle: nil), forCellWithReuseIdentifier: "Card")
    }
}

extension FirstViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Card", for: indexPath) as! CardCollectionViewCell
        cell.cardContentView.viewModel = self.viewModels[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Card", for: indexPath) as! CardCollectionViewCell
        cell.cardContentView.viewModel = self.viewModels[indexPath.row]
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCell", for: indexPath)
        }
        return UICollectionReusableView()
    }
}

extension FirstViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cardHorizontalOffset: CGFloat = 20
        let cardHeightByWidthRatio: CGFloat = 1.2
        let width = collectionView.bounds.size.width - 2 * cardHorizontalOffset
        let height: CGFloat = width * cardHeightByWidthRatio
        return CGSize(width: width, height: height)
    }

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

        let params = CardTransition.Params(
            fromCardFrame: cardPresentationFrameOnScreen,
            fromCardFrameWithoutTransform: cardFrameWithoutTransform,
            fromCell: cell)
        self.transition = CardTransition(params: params)
        detail.transitioningDelegate = self.transition

        // If `modalPresentationStyle` is not `.fullScreen`, this should be set to true to make status bar depends on presented vc.
        detail.modalPresentationCapturesStatusBarAppearance = true
        detail.modalPresentationStyle = .custom

        detail.viewModel = self.viewModels[indexPath.row]

        self.present(detail, animated: true)
    }
}
