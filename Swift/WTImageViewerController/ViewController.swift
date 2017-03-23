//
//  ViewController.swift
//  WTImageViewerController
//
//  Created by Jayce on 2017/3/22.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WTImageViewerControllerDelegate, URLSessionDownloadDelegate {

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
    
    func imageViewerController(_ controller: WTImageViewerController, downloadingImageForURL url: URL, progressHandler: WTImageViewerControllerDownloadingImageProgressHandler?, completionHandler: @escaping WTImageViewerControllerDownloadingImageCompletionHandler) -> Int {
        let downloadTask: URLSessionDownloadTask = session.downloadTask(with: url)
        progresses[downloadTask.taskIdentifier] = progressHandler
        completions[downloadTask.taskIdentifier] = completionHandler
//        print(#function + " downloadTask：\(downloadTask)")
        downloadTask.resume()
        return downloadTask.taskIdentifier
    }

    // MARK: URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        print(#function + " downloadTask：\(downloadTask)" + " location：\(location)")
        if let completion = completions[downloadTask.taskIdentifier] {
            do {
                let data = try Data.init(contentsOf: location)
                let image = UIImage(data: data)
                completion(image)
            } catch {
                print(error)
                completion(nil)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let progress = progresses[downloadTask.taskIdentifier] {
            let progressValue = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
//            print(#function + "\(progressValue)")
            progress(progressValue)
        }
    }
    
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
        present(imageViewerController, animated: true, completion: nil)
    }

    // MARK: Properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    lazy private var session: URLSession = {
        let sesstion = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        return sesstion
    }()
    
    private var progresses = [Int: WTImageViewerControllerDownloadingImageProgressHandler]()
    private var completions = [Int: WTImageViewerControllerDownloadingImageCompletionHandler]()
}

