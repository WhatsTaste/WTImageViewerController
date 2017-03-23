//
//  WTSectorProgressView.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/21.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

public class WTSectorProgressView: UIView {

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
        let startAngle = CGFloat(-M_PI / 2)
        let endAngle = min(progress, 1) * CGFloat(M_PI * 2) + startAngle
        path = UIBezierPath(arcCenter: center, radius: radius / 2 - borderWidth / 2 - innerInset + 1, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.addLine(to: center)
        path.close()
        path.miterLimit = 0
        sectorColor.setFill()
        path.fill()
    }
    
    // MARK: Public
    
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
    
    // MARK: Private
    
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
    
    // MARK: Properties
    
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
