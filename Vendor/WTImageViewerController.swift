//
//  WTImageViewerController.swift
//  WTImageViewerController
//
//  Created by Jayce on 2017/3/22.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

public typealias WTImageViewerControllerDownloadingImageProgressHandler = (_ progress: CGFloat) -> Void
public typealias WTImageViewerControllerDownloadingImageCompletionHandler = (_ image: UIImage?) -> Void

@objc public protocol WTImageViewerControllerDelegate: class {
    @objc optional func imageViewerController(_ controller: WTImageViewerController, downloadingImageForURL url: URL, progressHandler: WTImageViewerControllerDownloadingImageProgressHandler?, completionHandler: @escaping WTImageViewerControllerDownloadingImageCompletionHandler) -> Int
}

public let WTImageViewerControllerMargin: CGFloat = 10
private let WTImageViewerControllerAnimationDuration: TimeInterval = 0.2
private let reuseIdentifier = "Cell"
private let controlsViewHeight:CGFloat = 44

open class WTImageViewerController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    public convenience init(assets: [WTImageViewerAsset]) {
        self.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
        self.assets = assets
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        edgesForExtendedLayout = .all
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = UIColor.black
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        
        view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: -WTImageViewerControllerMargin))
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .right, relatedBy: .equal, toItem: collectionView, attribute: .right, multiplier: 1, constant: -WTImageViewerControllerMargin))
        view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .bottom, relatedBy: .equal, toItem: collectionView, attribute: .bottom, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint.init(item: pageControl, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .right, relatedBy: .equal, toItem: pageControl, attribute: .right, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .bottom, relatedBy: .equal, toItem: pageControl, attribute: .bottom, multiplier: 1, constant: 0))
        pageControl.addConstraint(NSLayoutConstraint.init(item: pageControl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: controlsViewHeight))
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard assets.count > 0 else {
            return
        }
        collectionView.collectionViewLayout.invalidateLayout()
        
        if shouldScrollToCurrentIndex {
            shouldScrollToCurrentIndex = false
        } else {
            return
        }
        if let index = index {
            collectionView.scrollToItem(at: IndexPath.init(item: index, section: 0), at: .left, animated: false)
        }
    }
    
    // Fix collectionView's cell bounds isn't equal to the whole subview, not matter how the constraints are
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.reloadData()
    }
    
    override open var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: UICollectionViewDataSource

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return assets.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! WTImageViewerCell
    
        // Configure the cell
        let asset = assets[indexPath.item]
        cell.index = indexPath.item
        cell.singleTapHandler = { [weak self] in
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        var requestID = self.requestIDs[indexPath.item] ?? 0
        let progress = progresses[indexPath.item] ?? 0
//        print(#function + ":\(indexPath.item) Using:" + "\(progress)")
        cell.contentButton.isHidden = !(failedFlags[indexPath.item] ?? false)
        cell.progressView.isHidden = !(requestID != 0)
        cell.progressView.progress = progress
        cell.contentImageView.contentMode = contentMode
        if let image = asset.image {
            cell.contentImageView.image = image
        } else if asset.imageURL != nil {
            if requestID == 0 {
                let request = {
                    requestID = self.delegate?.imageViewerController?(self, downloadingImageForURL: URL(string: asset.imageURL!)!, progressHandler: { [weak self, weak cell] (progress) in
                        guard self != nil else {
                            return
                        }
                        if cell?.index == indexPath.item {
                            let progressValue = CGFloat(max(progress, 0))
//                            print(#function + ":\(indexPath.item) Downloading:" + "\(progressValue)")
                            cell?.progressView.isHidden = false
                            cell?.progressView.progress = progressValue
                            self?.progresses[indexPath.item] = progressValue
                        }
                        }, completionHandler: { [weak self, weak cell] (image) in
                            guard self != nil else {
                                return
                            }
                            guard image != nil else {
                                cell?.contentButton.isHidden = false
                                self?.failedFlags[indexPath.item] = true
                                self?.progresses[indexPath.item] = nil
                                return
                            }
//                            print(#function + ":\(indexPath.item) Downloading ends with image size" + "\(image!.size)")
                            self?.requestIDs[indexPath.item] = 0
                            if cell?.index == indexPath.item {
                                cell?.contentImageView.image = image
                                cell?.progressView.isHidden = true
                                self?.failedFlags[indexPath.item] = nil
                                self?.progresses[indexPath.item] = nil
                            }
                    }) ?? 0
                    self.requestIDs[indexPath.item] = requestID
                }
                
                cell.contentButtonHandler = { (_) in
                    request()
                }
                
                request()
            }
        }
        cell.contentButton.isHidden = true
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let someCell = cell as? WTImageViewerCell {
            someCell.contentScrollView.zoomScale = someCell.contentScrollView.minimumZoomScale
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor(collectionView.bounds.width)
        let height = floor(collectionView.bounds.height)
        let size = CGSize(width: width, height: height)
//        print(size)
        return size
    }
    
    // MARK: UIScrollViewDelegate
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let indexPath = currentIndexPath() {
            let currentPage = indexPath.item
//            print(#function + " currentPage: \(currentPage)")
            pageControl.currentPage = currentPage
        }
    }
    
    // MARK: Private
    
    func currentIndexPath() -> IndexPath? {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)
        return visibleIndexPath
    }
    
    func currentImage() -> UIImage? {
        if let indexPath = currentIndexPath() {
            let cell = collectionView.cellForItem(at: indexPath) as! WTImageViewerCell
            return cell.contentImageView.image
        } else {
            return image
        }
    }
    
    // MARK: Properties
    
    weak public var delegate: WTImageViewerControllerDelegate?
    public var index: Int?
    public var duration: TimeInterval = WTImageViewerControllerAnimationDuration
    public var image: UIImage?
    public var contentMode: UIViewContentMode = .scaleToFill
    public weak var fromView : UIView? {
        didSet {
            if let someFromView = fromView, let somesSuperview = someFromView.superview {
                initialFrame = somesSuperview.convert(someFromView.frame, to: nil)
            }
        }
    }
    fileprivate var initialFrame: CGRect = .zero
    fileprivate var finalFrame: CGRect {
        get {
            if let indexPath = currentIndexPath() {
                let cell = collectionView.cellForItem(at: indexPath) as! WTImageViewerCell
                return cell.contentImageView.frame
            } else {
                let scale = min(view.bounds.width / initialFrame.width, view.bounds.height / initialFrame.height)
                let size = CGSize(width: initialFrame.width * scale, height: initialFrame.height * scale)
                return CGRect(x: 0, y: view.bounds.midY - size.height / 2, width: size.width, height: size.height)
            }
        }
    }
    
    private var assets: [WTImageViewerAsset]!
    lazy private var requestIDs: [Int: Int] = {
        let dictionry = [Int: Int]()
        return dictionry
    }()
    lazy private var failedFlags: [Int: Bool] = {
        let dictionry = [Int: Bool]()
        return dictionry
    }()
    private var progresses = [Int: CGFloat]()
    private var shouldScrollToCurrentIndex = true
    
    lazy private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WTImageViewerCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return collectionView
    }()
    
    lazy private var pageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: .zero)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.tintColor = UIColor.white
        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = self.assets.count
        return pageControl
    }()
}

// MARK: UIViewControllerTransitioningDelegate

extension WTImageViewerController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitioning = WTImageViewerControllerTransitioning(mode: .present)
        transitioning.duration = duration
        transitioning.image = currentImage()
        transitioning.contentMode = contentMode
        transitioning.fromView = fromView
        transitioning.initialFrame = initialFrame
        transitioning.finalFrame = finalFrame
        return transitioning
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitioning = WTImageViewerControllerTransitioning(mode: .dismiss)
        transitioning.duration = duration
        transitioning.image = currentImage()
        transitioning.contentMode = contentMode
        transitioning.fromView = fromView
        transitioning.initialFrame = initialFrame
        transitioning.finalFrame = finalFrame
        return transitioning
    }
}

fileprivate enum WTImageViewerControllerTransitioningMode {
    case present
    case dismiss
}

fileprivate class WTImageViewerControllerTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    convenience init(mode : WTImageViewerControllerTransitioningMode) {
        self.init()
        self.mode = mode
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    fileprivate func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    fileprivate func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        let maskView = UIView(frame: .zero)
        maskView.backgroundColor = UIColor.black
        let imageView = UIImageView(image: image)
        imageView.contentMode = contentMode
        containerView.addSubview(maskView)
        containerView.addSubview(imageView)
        
        if mode == .present {
            fromView?.alpha = 0
            let viewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            viewController!.view.layoutIfNeeded()
            
            maskView.alpha = 0
            maskView.frame = viewController!.view.bounds
            imageView.frame = initialFrame
            
            UIView.animate(withDuration: duration, animations: {
                maskView.alpha  = 1
                imageView.frame = self.finalFrame
            }, completion: { _ in
                maskView.removeFromSuperview()
                imageView.removeFromSuperview()
                containerView.addSubview(viewController!.view)
                transitionContext.completeTransition(true)
            })
        }
        
        if mode == .dismiss {
            let viewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            viewController!.view.removeFromSuperview()
            
            maskView.alpha = 1
            maskView.frame = viewController!.view.bounds
            imageView.frame = finalFrame
            
            UIView.animate(withDuration: duration, animations: {
                maskView.alpha  = 0
                imageView.frame = self.initialFrame
            }, completion: { _ in
                maskView.removeFromSuperview()
                viewController!.view.removeFromSuperview()
                self.fromView?.alpha = 1
                transitionContext.completeTransition(true)
            })
        }
    }
    
    // MARK: Properties
    
    var mode: WTImageViewerControllerTransitioningMode!
    var duration: TimeInterval = WTImageViewerControllerAnimationDuration
    var image: UIImage?
    var contentMode: UIViewContentMode = .scaleToFill
    weak var fromView : UIView?
    var initialFrame: CGRect = .zero
    var finalFrame: CGRect = .zero
}
