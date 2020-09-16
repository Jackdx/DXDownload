//
//  DownLoadViewController.m
//  DownLoadDemo
//
//  Created by 邓翔 on 2020/9/14.
//  Copyright © 2020 邓翔. All rights reserved.
//

#import "DownLoadViewController.h"
#import <DXDownload/DXDownloadManager.h>

@interface DownLoadViewController ()

@property (nonatomic, strong) NSURLSessionDownloadTask *downLoadTask;

@end

@implementation DownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    {
        UIButton *dlBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [dlBtn setBackgroundColor:UIColor.orangeColor];
        dlBtn.frame = CGRectMake(100, 300, 80, 30);
        [dlBtn setTitle:@"开始" forState:UIControlStateNormal];
        [dlBtn addTarget:self action:@selector(startDown) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:dlBtn];
    }
    {
        UIButton *dlBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [dlBtn setBackgroundColor:UIColor.orangeColor];
        dlBtn.frame = CGRectMake(100, 500, 80, 30);
        [dlBtn setTitle:@"暂停" forState:UIControlStateNormal];
        [dlBtn addTarget:self action:@selector(stopDown) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:dlBtn];
    }
}
- (void)downloadSource
{
    self.downLoadTask = [DXDownloadManager downloadTaskWithURL:self.sourceUrlStr path:[NSString documentPath] fileName:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"--------%f", downloadProgress.fractionCompleted);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = downloadProgress.fractionCompleted;
        });
    } completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (filePath) NSLog(@"url1-1 下载完成");
    }];
}
- (void)startDown
{
    [self downloadSource];
}
- (void)stopDown
{
    [self.downLoadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
    }];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.downLoadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
    }];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}
@end
