//
//  BaseDownViewController.h
//  DownLoadDemo
//
//  Created by 邓翔 on 2020/9/15.
//  Copyright © 2020 邓翔. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseDownViewController : UIViewController

@property (nonatomic, strong) UIProgressView *progressView;

- (void)downloadSource;

@property (nonatomic, copy) NSString *sourceUrlStr;
@property (nonatomic, strong) NSURL *sourceUrl;

@end

NS_ASSUME_NONNULL_END
