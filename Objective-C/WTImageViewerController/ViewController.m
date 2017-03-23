//
//  ViewController.m
//  WTImageViewerController
//
//  Created by Jayce on 2017/3/23.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

#import "ViewController.h"

#import "WTImageViewerController-Swift.h"

typedef void(^ProgressHandler)(CGFloat progress);
typedef void(^CompletionHandler)(UIImage * _Nullable image);

@interface ViewController () <WTImageViewerControllerDelegate, NSURLSessionDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, ProgressHandler> *progresses;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, CompletionHandler> *completions;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.imageView.backgroundColor = [UIColor blueColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WTImageViewerControllerDelegate

- (NSInteger)imageViewerController:(WTImageViewerController *)controller downloadingImageForURL:(NSURL *)url progressHandler:(void (^)(CGFloat))progressHandler completionHandler:(void (^)(UIImage * _Nullable))completionHandler {
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithURL:url];
    self.progresses[@(downloadTask.taskIdentifier)] = progressHandler;
    self.completions[@(downloadTask.taskIdentifier)] = completionHandler;
//    NSLog(@"%s%@", __PRETTY_FUNCTION__, downloadTask);
    [downloadTask resume];
    return downloadTask.taskIdentifier;
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    CompletionHandler completion = self.completions[@(downloadTask.taskIdentifier)];
    if (completion) {
        UIImage *image = nil;
        @try {
            NSData *data = [NSData dataWithContentsOfURL:location];
            image = [UIImage imageWithData:data];
        } @catch (NSException *exception) {
            NSLog(@"%s%@", __PRETTY_FUNCTION__, exception.reason);
        } @finally {
            completion(image);
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    ProgressHandler progress = self.progresses[@(downloadTask.taskIdentifier)];
    if (progress) {
        CGFloat progressValue = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
//        NSLog(@"%s%f", __PRETTY_FUNCTION__, progressValue);
        progress(progressValue);
    }
}

#pragma mark - Private

- (IBAction)showImageViewer:(UITapGestureRecognizer *)sender {
    WTImageViewerAsset *asset1 = [[WTImageViewerAsset alloc] initWithImageURL:@"http://eoimages.gsfc.nasa.gov/images/imagerecords/78000/78314/VIIRS_3Feb2012_lrg.jpg"];
    WTImageViewerAsset *asset2 = [[WTImageViewerAsset alloc] initWithImageURL:@"http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_b.jpg"];
    WTImageViewerAsset *asset3 = [[WTImageViewerAsset alloc] initWithImageURL:@"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_b.jpg"];
    WTImageViewerAsset *asset4 = [[WTImageViewerAsset alloc] initWithImageURL:@"http://farm4.static.flickr.com/3364/3338617424_7ff836d55f_b.jpg"];
    WTImageViewerAsset *asset5 = [[WTImageViewerAsset alloc] initWithImageURL:@"http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b_b.jpg"];
    WTImageViewerController *imageViewerController = [[WTImageViewerController alloc] initWithAssets:@[asset1, asset2, asset3, asset4, asset5]];
    imageViewerController.delegate = self;
    imageViewerController.image = self.imageView.image;
    imageViewerController.contentMode = self.imageView.contentMode;
    imageViewerController.fromView = self.imageView;
    [self presentViewController:imageViewerController animated:YES completion:nil];
}

#pragma mark - Properties

- (NSURLSession *)session {
    if (_session == nil) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (NSMutableDictionary<NSNumber *,ProgressHandler> *)progresses {
    if (_progresses == nil) {
        _progresses = [NSMutableDictionary dictionary];
    }
    return _progresses;
}

- (NSMutableDictionary<NSNumber *,CompletionHandler> *)completions {
    if (_completions == nil) {
        _completions = [NSMutableDictionary dictionary];
    }
    return _completions;
}

@end
