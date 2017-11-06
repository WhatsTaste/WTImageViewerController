//
//  WTImageViewerAsset.swift
//  WTImageViewerController
//
//  Created by Jayce on 2017/3/22.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

public class WTImageViewerAsset: NSObject {
    @objc public convenience init(image: UIImage) {
        self.init()
        self.image = image
    }
    
    @objc public convenience init(imageURL: String) {
        self.init()
        self.imageURL = imageURL
    }
    
    var image: UIImage?
    var imageURL: String?
}
