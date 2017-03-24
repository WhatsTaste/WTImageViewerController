//
//  ViewController.swift
//  WTImageViewerController
//
//  Created by Jayce on 2017/3/22.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WTImageViewerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imageView.backgroundColor = UIColor.blue
        imageView.contentMode = .scaleAspectFit
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: WTImageViewerControllerDelegate
    
//    func imageViewerController(_ controller: WTImageViewerController, imageAtIndex index: Int, url: URL) -> UIImage? {
////        print(#file + " [\(#line)]" + " \(#function): " + "\(index)" + ": \(url)")
//        return images[url]
//    }
//    
//    func imageViewerController(_ controller: WTImageViewerController, didFinishDownloadingImage image: UIImage?, index: Int, url: URL) {
////        print(#file + " [\(#line)]" + " \(#function): " + "\(index)" + ": \(url)")
//        imageView.image = image
//        images[url] = image
//    }
    
    // MARK: Private
    
    @IBAction func showImageViewer(_ sender: UITapGestureRecognizer) {
        let asset1 = WTImageViewerAsset(imageURL: "http://eoimages.gsfc.nasa.gov/images/imagerecords/78000/78314/VIIRS_3Feb2012_lrg.jpg")
        let asset2 = WTImageViewerAsset(imageURL: "http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_b.jpg")
        let asset3 = WTImageViewerAsset(imageURL: "http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_b.jpg")
        let asset4 = WTImageViewerAsset(imageURL: "http://farm4.static.flickr.com/3364/3338617424_7ff836d55f_b.jpg")
        let asset5 = WTImageViewerAsset(imageURL: "http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b_b.jpg")
        let imageViewerController = WTImageViewerController(assets: [asset1, asset2, asset3, asset4, asset5])
        imageViewerController.delegate = self
        imageViewerController.image = imageView.image
        imageViewerController.contentMode = imageView.contentMode
        imageViewerController.fromView = imageView
        imageViewerController.imageHandler = { [weak self] (_, index, url) in
            print(#file + " [\(#line)]" + " \(#function): " + "\(index)" + ": \(url)")
            return self?.images[url]
        }
        imageViewerController.didFinishDownloadingImageHandler = { [weak self] (_, image, index, url) in
            print(#file + " [\(#line)]" + " \(#function): " + "\(index)" + ": \(url)")
            self?.imageView.image = image
            self?.images[url] = image
        }
        present(imageViewerController, animated: true, completion: nil)
    }

    // MARK: Properties
    
    @IBOutlet weak var imageView: UIImageView!
    lazy private var images: [URL: UIImage] = {
        let dictionry = [URL: UIImage]()
        return dictionry
    }()
}

