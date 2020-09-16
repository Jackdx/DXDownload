//
//  DXViewController.m
//  DXDownload
//
//  Created by Jackdx on 09/15/2020.
//  Copyright (c) 2020 Jackdx. All rights reserved.
//

#import "DXViewController.h"
#import "DownLoadViewController.h"
#import "AutoDownLoadViewController.h"

@interface DXViewController ()

@end

@implementation DXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setupUI];
}

- (void)setupUI
{
    {
        UIButton *dlBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [dlBtn setBackgroundColor:UIColor.orangeColor];
        dlBtn.frame = CGRectMake(100, 100, 80, 30);
        [dlBtn setTitle:@"普通下载" forState:UIControlStateNormal];
        [dlBtn addTarget:self action:@selector(downVc) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:dlBtn];
    }
    {
        UIButton *dlBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [dlBtn setBackgroundColor:UIColor.yellowColor];
        dlBtn.frame = CGRectMake(100, 300, 80, 30);
        [dlBtn setTitle:@"自动下载" forState:UIControlStateNormal];
        [dlBtn addTarget:self action:@selector(autoDownVc) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:dlBtn];
    }
}
- (void)downVc
{
    DownLoadViewController *downVc = [[DownLoadViewController alloc] init];
    downVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:downVc animated:YES completion:nil];
}
- (void)autoDownVc
{
    AutoDownLoadViewController *autoDownVc = [[AutoDownLoadViewController alloc] init];
    autoDownVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:autoDownVc animated:YES completion:nil];
}
@end
