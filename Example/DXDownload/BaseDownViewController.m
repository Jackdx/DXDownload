//
//  BaseDownViewController.m
//  DownLoadDemo
//
//  Created by 邓翔 on 2020/9/15.
//  Copyright © 2020 邓翔. All rights reserved.
//

#import "BaseDownViewController.h"

@interface BaseDownViewController ()



@end

@implementation BaseDownViewController
- (UIProgressView *)progressView
{
    if (!_progressView) {
        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView.progressTintColor = UIColor.darkGrayColor; //进度颜色
        progressView.trackTintColor = UIColor.lightGrayColor; //剩余进度颜色
//        progressView.progressTintColor = UIColor.blackColor; //进度颜色
//        progressView.trackTintColor = UIColor.orangeColor; //剩余进度颜色
        progressView.progress = 0.0;
        progressView.layer.cornerRadius = 2;
        progressView.clipsToBounds = YES;
        _progressView = progressView;
    }
    return _progressView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sourceUrlStr = @"https://dldir1.qq.com/invc/tt/QB/Jietu/Jietu_2.2.2(11054).dmg";
    self.sourceUrl = [NSURL URLWithString:self.sourceUrlStr];
    
    self.progressView.frame = CGRectMake(10, 100, 300, 4);
    [self.view addSubview:self.progressView];
    
}

- (void)downloadSource
{
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
