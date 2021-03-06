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
        contentView.addSubview(progressView)
        contentScrollView.addSubview(contentImageView)
        
        contentView.addConstraint(NSLayoutConstraint.init(item: contentScrollView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: WTImageViewerControllerMargin))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .right, relatedBy: .equal, toItem: contentScrollView, attribute: .right, multiplier: 1, constant: WTImageViewerControllerMargin))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentScrollView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: contentScrollView, attribute: .bottom, multiplier: 1, constant: 0))
        
        contentView.addConstraint(NSLayoutConstraint.init(item: progressView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: progressView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        progressView.addConstraint(NSLayoutConstraint.init(item: progressView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60))
        progressView.addConstraint(NSLayoutConstraint.init(item: progressView, attribute: .height, relatedBy: .equal, toItem: progressView, attribute: .width, multiplier: 1, constant: 0))
        
        contentScrollView.addConstraint(NSLayoutConstraint.init(item: contentImageView, attribute: .left, relatedBy: .equal, toItem: contentScrollView, attribute: .left, multiplier: 1, constant: 0))
        contentScrollView.addConstraint(NSLayoutConstraint.init(item: contentScrollView, attribute: .right, relatedBy: .equal, toItem: contentImageView, attribute: .right, multiplier: 1, constant: 0))
        contentScrollView.addConstraint(NSLayoutConstraint.init(item: contentImageView, attribute: .top, relatedBy: .equal, toItem: contentScrollView, attribute: .top, multiplier: 1, constant: 0))
        contentScrollView.addConstraint(NSLayoutConstraint.init(item: contentScrollView, attribute: .bottom, relatedBy: .equal, toItem: contentImageView, attribute: .bottom, multiplier: 1, constant: 0))
        
        contentView.addGestureRecognizer(singleTapGestureRecognizer)
        contentView.addGestureRecognizer(doubleTapGestureRecognizer)
        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateContentSize()
        
        updateContentInset()
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
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInset()
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: contentView)
        let inside = contentButton.frame.contains(location)
        //        print(#function + "\(location)" + "inside: \(inside)")
        return contentButton.isHidden || !inside
    }
    
    // MARK: - Private
    
    @objc private func singleTapAction(_ sender: UITapGestureRecognizer) {
        singleTapHandler?()
    }

    @objc private func doubleTapAction(_ sender: UITapGestureRecognizer) {
        if contentScrollView.zoomScale > contentScrollView.minimumZoomScale {
            contentScrollView.setZoomScale(contentScrollView.minimumZoomScale, animated: true)
        } else {
            let location = sender.location(in: contentImageView)
            let zoomScale = contentScrollView.maximumZoomScale
            let size = contentScrollView.bounds.size
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
    
    private func updateContentSize() {
        guard let someImage = contentImageView.image else {
            return
        }
        let bounds = contentScrollView.bounds
        let imageSize = someImage.size
        let scale: CGFloat = bounds.width / imageSize.width
        let factor: CGFloat = imageSize.height / imageSize.width
        let contentSize = CGSize(width: bounds.width, height: floor(bounds.width * factor))
        contentScrollView.contentSize = contentSize
        self.contentSize = contentSize
//        print(#function + "\(contentSize)")
        contentScrollView.minimumZoomScale = scale
        contentScrollView.maximumZoomScale = contentScrollView.minimumZoomScale * 3
        contentScrollView.zoomScale = contentScrollView.minimumZoomScale
    }
    
    private func updateContentInset() {
        var x: CGFloat = 0
        var y: CGFloat = 0
        if contentSize.width < contentScrollView.bounds.width {
            x = (contentScrollView.bounds.width - contentSize.width) / 2
        }
        if contentSize.height < contentScrollView.bounds.height {
            y = (contentScrollView.bounds.height - contentSize.height) / 2
        }
        x -= contentScrollView.frame.minX - WTImageViewerControllerMargin
        y -= contentScrollView.frame.minY
        contentScrollView.contentInset = .init(top: y, left: x, bottom: y, right: x)
//        print(#function + "contentInset: \(contentScrollView.contentInset) contentSize: \(contentSize) bounds: \(contentScrollView.bounds)")
    }
    
    // MARK: - Properties
    
    public var index: Int!
    public var singleTapHandler: WTImageViewerCellTapHandler?
    public var contentButtonHandler: WTImageViewerCellContentButtonHandler?
    
    lazy public private(set) var contentImageView: UIImageView = {
        let imageView = WTImageViewerCellImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.imageDidSetHandler = { [weak self] (image) in
            guard self != nil else {
                return
            }
            self!.setNeedsLayout()
        }
        return imageView
    }()
    
    lazy public private(set) var progressView: WTImageViewerCellSectorProgressView = {
        let view = WTImageViewerCellSectorProgressView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.isHidden = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        return view
    }()
    
    lazy public private(set) var contentButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.setTitleColor(UIColor.red, for: .normal)
        button.setTitle(self.WTIVLocalizedString("Retry"), for: .normal)
        button.addTarget(self, action: #selector(contentButtonAction(_:)), for: .touchUpInside)
        self.contentView.addSubview(button)
        self.contentView.addConstraint(NSLayoutConstraint.init(item: button, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self.contentView, attribute: .left, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: .right, relatedBy: .greaterThanOrEqual, toItem: button, attribute: .right, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: button, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: button, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0))
        return button
    }()
    
    lazy public private(set) var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.contentView.bounds.insetBy(dx: WTImageViewerControllerMargin, dy: 0))
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
        scrollView.delegate = self
        return scrollView
    }()
    
    lazy private var singleTapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()
//
    lazy private var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        gestureRecognizer.numberOfTapsRequired = 2
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()
    
    private var contentSize: CGSize = .zero
}

typealias WTImageViewerCellImageViewHandler = (_ image: UIImage?) -> Void

class WTImageViewerCellImageView: UIImageView {
    override var image: UIImage? {
        didSet {
            imageDidSetHandler?(image)
        }
    }
    
    // MARK: - Properties
    
    var imageDidSetHandler: WTImageViewerCellImageViewHandler?
}

public class WTImageViewerCellSectorProgressView: UIView {
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        // Drawing code
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(rect)
        context?.restoreGState()
        
        let radius = min(rect.width, rect.height) - borderWidth
        let bounds = CGRect(x: (rect.width - radius) / 2, y: (rect.height - radius) / 2, width: radius, height: radius)
        var path = UIBezierPath(ovalIn: bounds)
        context?.saveGState()
        borderColor.setStroke()
        fillColor.setFill()
        path.lineWidth = borderWidth
        path.fill()
        path.stroke()
        context?.restoreGState()
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let startAngle = CGFloat(-Double.pi / 2)
        let endAngle = min(progress, 1) * CGFloat(Double.pi * 2) + startAngle
        path = UIBezierPath(arcCenter: center, radius: radius / 2 - borderWidth / 2 - innerInset + 1, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.addLine(to: center)
        path.close()
        path.miterLimit = 0
        sectorColor.setFill()
        path.fill()
    }
    
    // MARK: - Public
    
    public func setProgress(_ progress: CGFloat, animated: Bool) {
        if animated {
            currentLink?.invalidate()
            targetProgress = progress
            let link = CADisplayLink(target: self, selector: #selector(changeProgress))
            link.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            progressStep = (progress - self.progress) / CGFloat(animationDuration * 60 / TimeInterval(link.frameInterval))
            currentLink = link
        } else {
            self.progress = progress
        }
    }
    
    // MARK: - Private
    
    @objc private func changeProgress() {
        guard let target = targetProgress else {
            return
        }
        let newProgress = progressStep + progress
        progress = newProgress
        if abs(target - progress) < 0.000001 {
            progress = target
            currentLink?.invalidate()
            targetProgress = nil
        }
    }
    
    // MARK: - Properties
    
    public var progress: CGFloat = 0 {
        didSet {
            if progress != oldValue {
                setNeedsDisplay()
            }
        }
    }
    public var borderColor: UIColor = UIColor.white
    public var fillColor: UIColor = UIColor.clear
    public var sectorColor: UIColor = UIColor.white
    public var borderWidth: CGFloat = 3
    public var innerInset: CGFloat = 0
    
    private var targetProgress: CGFloat?
    private var progressStep: CGFloat = 1
    private var currentLink: CADisplayLink?
    private var animationDuration: TimeInterval = 1
}
