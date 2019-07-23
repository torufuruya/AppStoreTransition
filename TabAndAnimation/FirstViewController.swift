//
//  FirstViewController.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/18.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

class CardCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        // Page width used for estimating and calculating paging.
        let pageWidth = self.itemSize.width + self.minimumLineSpacing

        // Make an estimation of the current page position.
        let approximatePage = self.collectionView!.contentOffset.x/pageWidth

        // Determine the current page based on velocity.
        let currentPage = (velocity.x < 0.0) ? floor(approximatePage) : ceil(approximatePage)

        // Create custom flickVelocity.
        let flickVelocity = velocity.x * 0.3

        // Check how many pages the user flicked, if <= 1 then flickedPages should return 0.
        let flickedPages = (abs(round(flickVelocity)) <= 1) ? 0 : round(flickVelocity)

        // Calculate newHorizontalOffset.
        let newHorizontalOffset = ((currentPage + flickedPages) * pageWidth) - self.collectionView!.contentInset.left

        return CGPoint(x: newHorizontalOffset, y: proposedContentOffset.y)
    }
}

class FirstViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewForSmall: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

    private var transition: CardTransition?

    private var viewModels = [
        CardContentViewModel(image: #imageLiteral(resourceName: "image1"), primary: "3月", secondary: "¥3,400"),
        CardContentViewModel(image: #imageLiteral(resourceName: "image2"), primary: "4月", secondary: "¥120,000"),
        CardContentViewModel(image: #imageLiteral(resourceName: "image1"), primary: "5月", secondary: "¥25,000")
    ]

    private let smallCardCollection = SmallCardCollection()

    override func viewDidLoad() {
        super.viewDidLoad()

        //----------------
        // Card Collection View
        //----------------
        self.collectionView.delaysContentTouches = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.clipsToBounds = false
        self.collectionView.register(UINib(nibName: "\(CardCollectionViewCell.self)", bundle: nil), forCellWithReuseIdentifier: "Card")

        let cardLayout = CardCollectionViewFlowLayout()
        cardLayout.scrollDirection = .horizontal
        cardLayout.sectionInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        self.collectionView.collectionViewLayout = cardLayout

        //----------------
        // Small Card Collection View
        //----------------
        self.collectionViewForSmall.delaysContentTouches = false
        self.smallCardCollection.viewController = self
        self.collectionViewForSmall.delegate = smallCardCollection
        self.collectionViewForSmall.dataSource = smallCardCollection
        self.collectionViewForSmall.clipsToBounds = false
        self.collectionViewForSmall.register(UINib(nibName: "\(CardCollectionViewCell.self)", bundle: nil), forCellWithReuseIdentifier: "SmallCard")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let cardLayout = self.collectionView.collectionViewLayout as? CardCollectionViewFlowLayout {
            let cardHorizontalOffset = cardLayout.sectionInset.left
            let cardHeightByWidthRatio: CGFloat = 0.6
            let width = collectionView.bounds.size.width - 2 * cardHorizontalOffset
            let height: CGFloat = width * cardHeightByWidthRatio
            self.collectionViewHeight.constant = height
            cardLayout.itemSize = CGSize(width: width, height: height)
        }
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
}

extension FirstViewController: UICollectionViewDelegateFlowLayout {

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

class SmallCardCollection: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {

    var viewController: UIViewController?

    private var transition: SmallCardTransition?

    private var viewModels = [
        CardContentViewModel(image: #imageLiteral(resourceName: "image1"), primary: "3月", secondary: "¥3,400"),
        CardContentViewModel(image: #imageLiteral(resourceName: "image2"), primary: "4月", secondary: "¥120,000"),
        CardContentViewModel(image: #imageLiteral(resourceName: "image1"), primary: "5月", secondary: "¥25,000"),
        CardContentViewModel(image: #imageLiteral(resourceName: "image2"), primary: "6月", secondary: "¥12,300"),
        CardContentViewModel(image: #imageLiteral(resourceName: "image1"), primary: "7月", secondary: "¥7,700")
    ]

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SmallCard", for: indexPath) as! CardCollectionViewCell
        cell.cardContentView.viewModel = self.viewModels[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SmallCard", for: indexPath) as! CardCollectionViewCell
        cell.cardContentView.viewModel = self.viewModels[indexPath.row]
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
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

        let params = SmallCardTransition.Params(
            fromCardFrame: cardPresentationFrameOnScreen,
            fromCardFrameWithoutTransform: cardFrameWithoutTransform,
            fromCell: cell)
        self.transition = SmallCardTransition(params: params)
        detail.transitioningDelegate = self.transition

        // If `modalPresentationStyle` is not `.fullScreen`, this should be set to true to make status bar depends on presented vc.
        detail.modalPresentationCapturesStatusBarAppearance = true
        detail.modalPresentationStyle = .custom

        detail.viewModel = self.viewModels[indexPath.row]

        self.viewController?.present(detail, animated: true)
    }
}
