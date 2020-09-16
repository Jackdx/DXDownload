//
//  AFNDownLoadViewController.m
//  DownLoadDemo
//
//  Created by 邓翔 on 2020/9/15.
//  Copyright © 2020 邓翔. All rights reserved.
//

#import "AutoDownLoadViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <DXDownload/DXDownloadManager.h>

@interface AutoDownLoadViewController ()

@property (nonatomic, strong) NSURLSessionDownloadTask *downLoadTask;

@end

@implementation AutoDownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self downloadSource];
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
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.downLoadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
    }];
}
- (void)willEnterForeground
{
    // 延时是因为进入后台后网络会中断，再次到达前台才会报错ResumeData。等保存后再进行下载
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self downloadSource];
    });
    
}

@end
