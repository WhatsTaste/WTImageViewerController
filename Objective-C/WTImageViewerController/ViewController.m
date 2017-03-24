//
//  ViewController.m
//  WTImageViewerController
//
//  Created by Jayce on 2017/3/23.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

#import "ViewController.h"

#import "WTImageViewerController-Swift.h"

@interface ViewController () <WTImageViewerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSMutableDictionary<NSURL *, UIImage *> *images;

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

- (UIImage *)imageViewerController:(WTImageViewerController *)controller imageAtIndex:(NSInteger)index url:(NSURL *)url {
//    NSLog(@"%s %ld %@", __PRETTY_FUNCTION__, (long)index, url);
    return self.images[url];
}

- (void)imageViewerController:(WTImageViewerController *)controller didFinishDownloadingImage:(UIImage *)image index:(NSInteger)index url:(NSURL *)url {
//    NSLog(@"%s %ld %@", __PRETTY_FUNCTION__, (long)index, url);
    self.imageView.image = image;
    self.images[url] = image;
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

- (NSMutableDictionary<NSURL *,UIImage *> *)images {
    if (_images == nil) {
        _images = [NSMutableDictionary dictionary];
    }
    return _images;
}

@end
