//
//  WTImageViewerCell.swift
//  WTImageViewerController
//
//  Created by Jayce on 2017/3/22.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

typealias WTImageViewerCellTapHandler = @convention(block) () -> Void
typealias WTImageViewerCellContentButtonHandler = @convention(block) (_ sender: UIButton) -> Void

class WTImageViewerCell: UICollectionViewCell, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialization code
        contentView.clipsToBounds = true
        contentView.addSubview(contentScrollView)
        contentScrollView.addSubview(contentImageView)
        contentView.addSubview(progressView)
        
        contentView.addConstraint(NSLayoutConstraint.init(item: contentScrollView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: WTImageViewerControllerMargin))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .right, relatedBy: .equal, toItem: contentScrollView, attribute: .right, multiplier: 1, constant: WTImageViewerControllerMargin))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentScrollView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: contentScrollView, attribute: .bottom, multiplier: 1, constant: 0))
        
        contentImageViewLeftConstraint = NSLayoutConstraint.init(item: contentImageView, attribute: .left, relatedBy: .equal, toItem: contentScrollView, attribute: .left, multiplier: 1, constant: WTImageViewerControllerMargin)
        contentImageViewRightConstraint = NSLayoutConstraint.init(item: contentScrollView, attribute: .right, relatedBy: .equal, toItem: contentImageView, attribute: .right, multiplier: 1, constant: WTImageViewerControllerMargin)
        contentImageViewTopConstraint = NSLayoutConstraint.init(item: contentImageView, attribute: .top, relatedBy: .equal, toItem: contentScrollView, attribute: .top, multiplier: 1, constant: 0)
        contentImageViewBottomConstraint = NSLayoutConstraint.init(item: contentScrollView, attribute: .bottom, relatedBy: .equal, toItem: contentImageView, attribute: .bottom, multiplier: 1, constant: 0)
        contentScrollView.addConstraints([contentImageViewLeftConstraint, contentImageViewRightConstraint, contentImageViewTopConstraint, contentImageViewBottomConstraint])
        
        contentView.addConstraint(NSLayoutConstraint.init(item: progressView, attribute: .centerX, relatedBy: .equal, toItem: contentScrollView, attribute: .centerX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: progressView, attribute: .centerY, relatedBy: .equal, toItem: contentScrollView, attribute: .centerY, multiplier: 1, constant: 0))
        progressView.addConstraint(NSLayoutConstraint.init(item: progressView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60))
        progressView.addConstraint(NSLayoutConstraint.init(item: progressView, attribute: .height, relatedBy: .equal, toItem: progressView, attribute: .width, multiplier: 1, constant: 0))
        
        contentView.addGestureRecognizer(singleTapGestureRecognizer)
        contentView.addGestureRecognizer(doubleTapGestureRecognizer)
        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contentScrollView.zoomScale = contentScrollView.minimumZoomScale
        contentImageView.image = nil
        progressView.progress = 0
        progressView.isHidden = true
    }
    
    // MARK: UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentImageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        //        print(#function + ":\(scrollView.zoomScale)")
        scrollView.panGestureRecognizer.isEnabled = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // There is a bug, especially prevalent on iPhone 6 Plus, that causes zooming to render all other gesture recognizers ineffective.
        // This bug is fixed by disabling the pan gesture recognizer of the scroll view when it is not needed.
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            scrollView.panGestureRecognizer.isEnabled = false
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: contentView)
        let inside = contentButton.frame.contains(location)
        //        print(#function + "\(location)" + "inside: \(inside)")
        return contentButton.isHidden || !inside
    }
    
    // MARK: Private
    
    @objc private func singleTapAction(_ sender: UITapGestureRecognizer) {
        singleTapHandler?()
    }
    
    @objc private func doubleTapAction(_ sender: UITapGestureRecognizer) {
        if contentScrollView.zoomScale > contentScrollView.minimumZoomScale {
            contentScrollView.setZoomScale(contentScrollView.minimumZoomScale, animated: true)
        } else {
            let location = sender.location(in: contentImageView)
            let zoomScale = contentScrollView.maximumZoomScale
            let size = bounds.size
            let width = size.width / zoomScale
            let height = size.height / zoomScale
            let x = location.x - width / 2
            let y = location.y - height / 2
            let rect = CGRect(x: x, y: y, width: width, height: height)
            //            print(#function + "\(rect)")
            contentScrollView.zoom(to: rect, animated: true)
        }
    }
    
    @objc private func contentButtonAction(_ sender: UIButton) {
        contentButtonHandler?(sender)
    }
    
    func makeContentCenter() {
//        print(#function + " \(contentScrollView.bounds) VS \(contentView.bounds)")
        if let image = contentImageView.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let width = contentScrollView.bounds.size.width
            let height = contentScrollView.bounds.size.height
            
            let horizontalPadding = max((width - contentScrollView.zoomScale * imageWidth) / 2, 0)
            let verticalPadding = max((height - contentScrollView.zoomScale * imageHeight) / 2, 0)
            
            contentImageViewLeftConstraint.constant = horizontalPadding
            contentImageViewRightConstraint.constant = horizontalPadding
            contentImageViewTopConstraint.constant = verticalPadding
            contentImageViewBottomConstraint.constant = verticalPadding
        }
    }
    
    // MARK: Properties
    
    public var index: Int!
    public var singleTapHandler: WTImageViewerCellTapHandler?
    public var contentButtonHandler: WTImageViewerCellContentButtonHandler?
    
    lazy public private(set) var contentImageView: UIImageView = {
        let imageView = WTImageViewerCellImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.imageDidSetHandler = { [weak self] (image) in
            if self == nil {
                return
            }
            
            let bounds = self!.contentView.bounds.insetBy(dx: WTImageViewerControllerMargin, dy: 0)
            let imageSize = image?.size ?? CGSize.zero
            var scale: CGFloat = min(bounds.width / imageSize.width, bounds.height / imageSize.height)
            scale = min(scale, 1)
            let scaledImageSize = CGSize(width: floor(imageSize.width * scale), height: floor(imageSize.height * scale))
            self!.contentScrollView.minimumZoomScale = scale
            self!.contentScrollView.zoomScale = self!.contentScrollView.minimumZoomScale
            self!.contentScrollView.contentSize = scaledImageSize
            
            self!.makeContentCenter()
        }
        return imageView
    }()
    
    lazy public private(set) var progressView: WTSectorProgressView = {
        let view = WTSectorProgressView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.isHidden = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        return view
    }()
    
    lazy public private(set) var contentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.setTitleColor(UIColor.red, for: .normal)
        button.setTitle("Retry", for: .normal)
        button.addTarget(self, action: #selector(contentButtonAction(_:)), for: .touchUpInside)
        self.contentView.addSubview(button)
        self.contentView.addConstraint(NSLayoutConstraint.init(item: button, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self.contentView, attribute: .left, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: .right, relatedBy: .greaterThanOrEqual, toItem: button, attribute: .right, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: button, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: button, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0))
        return button
    }()
    
    lazy public private(set) var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds.insetBy(dx: WTImageViewerControllerMargin, dy: WTImageViewerControllerMargin))
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.black
        scrollView.isMultipleTouchEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.scrollsToTop = false
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        scrollView.maximumZoomScale = 2
        scrollView.delegate = self
        return scrollView
    }()
    
    lazy private var singleTapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()
    
    lazy private var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        gestureRecognizer.numberOfTapsRequired = 2
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()
    
    weak var contentImageViewLeftConstraint: NSLayoutConstraint!
    weak var contentImageViewRightConstraint: NSLayoutConstraint!
    weak var contentImageViewTopConstraint: NSLayoutConstraint!
    weak var contentImageViewBottomConstraint: NSLayoutConstraint!
    
    lazy private var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.scheduleRepeating(deadline: .now(), interval: .seconds(1))
        timer.setEventHandler { [weak self] in
            self?.progressView.isHidden = false
            let progress = CGFloat(arc4random_uniform(10)) / 10
            self?.progressView.progress = max(progress, 0.02)
        }
        return timer
    }()
}

typealias WTImageViewerCellImageViewHandler = (_ image: UIImage?) -> Void

class WTImageViewerCellImageView: UIImageView {
    override var image: UIImage? {
        didSet {
            imageDidSetHandler?(image)
        }
    }
    
    // MARK: Properties
    
    var imageDidSetHandler: WTImageViewerCellImageViewHandler?
}
