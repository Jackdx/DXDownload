//
//  DXDownloadManager.h
//  DownLoad
//
//  Created by Jackdx on 09/15/2020.
//  Copyright (c) 2020 Jackdx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Addition.h"

NS_ASSUME_NONNULL_BEGIN
typedef NSURL * _Nullable (^DXDownloadManagerDestination)(NSURL *targetPath, NSURLResponse *response);
typedef void (^DXDownloadmanagerProgress)(NSProgress *downloadProgress);
typedef void(^DXDownloadManagerCompletion)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error);

@interface DXDownloadManager : NSObject

+ (void)downloadTaskWithURL:(NSString *)url path:(NSString *)path completionHandler:(DXDownloadManagerCompletion)completionHandler;
+ (void)downloadTaskWithURL:(NSString *)url path:(NSString *)path fileName:(nullable NSString *)fileName completionHandler:(DXDownloadManagerCompletion)completionHandler;
+ (void)downloadTaskWithURL:(NSString *)url path:(NSString *)path fileName:(nullable NSString *)fileName progress:(DXDownloadmanagerProgress)progress completionHandler:(DXDownloadManagerCompletion)completionHandler;

@end

NS_ASSUME_NONNULL_END
