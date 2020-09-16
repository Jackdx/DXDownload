//
//  DXDownloadManager.m
//  DownLoad
//
//  Created by Jackdx on 09/15/2020.
//  Copyright (c) 2020 Jackdx. All rights reserved.
//

#import "DXDownloadManager.h"
#import <AFNetworking/AFNetworking.h>
#import "DXCache.h"

#define DXDOWNLOAD_RESUME_DATA_MAP  @"DXDownloadResumeDataMap"
#define DXDOWNLOAD_TASK_TEMP_MAP    @"DXDownloadTaskTempMap"
#define DXDOWNLOAD_COUNT            5

@interface DXURLSessionDownloadFile : NSObject

@property (nonatomic, copy) NSString *path;

@end

@implementation DXURLSessionDownloadFile

@end

@interface DXURLSessionDownloadTask : NSObject

@property (nonatomic, strong) DXURLSessionDownloadFile *downloadFile;
@property (nonatomic, assign) BOOL needFinish;

@end

@implementation DXURLSessionDownloadTask

@end

@implementation DXDownloadManager

static AFURLSessionManager *_sessionManager;
static dispatch_semaphore_t _semaphore;
static dispatch_queue_t _resumeDataQueue;
static dispatch_queue_t _tempFileQueue;
static dispatch_queue_t _downloadComsQueue;
static NSMutableArray *_downloadingList;
static NSMutableDictionary *_downloadCompletionList;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        _resumeDataQueue = dispatch_queue_create("rw_queue", DISPATCH_QUEUE_CONCURRENT);
        _tempFileQueue = dispatch_queue_create("temp_rw_queue", DISPATCH_QUEUE_CONCURRENT);
        _downloadComsQueue = dispatch_queue_create("download_coms_queue", DISPATCH_QUEUE_CONCURRENT);
        _semaphore = dispatch_semaphore_create(DXDOWNLOAD_COUNT);
        _downloadingList = [NSMutableArray new];
        _downloadCompletionList = [NSMutableDictionary new];
    });
}

+ (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSString *)url path:(NSString *)path completionHandler:(DXDownloadManagerCompletion)completionHandler {
   return [self downloadTaskWithURL:url path:path fileName:nil completionHandler:completionHandler];
}

+ (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSString *)url path:(NSString *)path fileName:(nullable NSString *)fileName completionHandler:(DXDownloadManagerCompletion)completionHandler {
    DXDownloadmanagerProgress progress = ^(NSProgress *downloadProgress) {
        if ([downloadProgress.localizedDescription containsString:@"100%"]) NSLog(@"url ---%@, localizedDescription --- %@, localizedAdditionalDescription --- %@", url, downloadProgress.localizedDescription, downloadProgress.localizedAdditionalDescription);
    };
   return [self downloadTaskWithURL:url path:path fileName:fileName progress:progress completionHandler:completionHandler];
}

+ (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSString *)url path:(NSString *)path fileName:(nullable NSString *)fileName progress:(DXDownloadmanagerProgress)progress completionHandler:(DXDownloadManagerCompletion)completionHandler {
    if (![url isNonEmpty] || ![path isNonEmpty]) {
        completionHandler(nil, nil, [NSError new]);
    }
    [self saveDownloadCompletion:completionHandler url:url];
    if ([self isDownlongdingWithUrl:url]) return nil;
    NSURLSessionDownloadTask *task = nil;
    NSData *resumeData = [self getResumeDataWithUrl:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    DXDownloadManagerDestination destinationBlock = ^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:[path stringByAppendingPathComponent:fileName ?: response.suggestedFilename]];
    };
    DXDownloadManagerCompletion completeBlock = ^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (!error) {// 任务完成或暂停下载
            [self removeResumeDataWithUrl:url];
            [self removeTaskWithUrl:url];
        } else  {// 部分网络出错，会返回resumeData
            NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
            if (resumeData) {
                [self saveResumeData:resumeData url:url];
            } else {
                [self removeResumeDataWithUrl:url];
                [self removeTaskWithUrl:url];
            }
        }
        
        NSMutableArray <DXDownloadManagerCompletion>*coms = _downloadCompletionList[[url stringFromMD5]];
        for (DXDownloadManagerCompletion com in coms) {
            com(response, filePath, error);
        }
        [self removeDownloadCompletionWithUrl:url];
        [self removeDownloadingWithUrl:url];
        
        dispatch_semaphore_signal(_semaphore);
#if !OS_OBJECT_USE_OBJC
        dispatch_release(semaphore);
#endif
    };
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    if (resumeData) {
        NSLog(@"继续下载");
        task = [_sessionManager downloadTaskWithResumeData:resumeData
                                                  progress:progress
                                               destination:destinationBlock
                                         completionHandler:completeBlock];
    } else {
        task = [_sessionManager downloadTaskWithRequest:request
                                               progress:progress
                                            destination:destinationBlock
                                      completionHandler:completeBlock];
    }
    [self saveDownloadingWithUrl:url];
    [self saveTask:task url:url];
    [task resume];
    return task;
}

+ (void)saveTask:(NSURLSessionDownloadTask *)task url:(NSString *)url {
    if (!task || ![url isNonEmpty]) return;
    url = [url stringFromMD5];
    DXURLSessionDownloadTask *alTask = (DXURLSessionDownloadTask *)task;
    NSString *tempPath = alTask.downloadFile.path;
    if (!tempPath) return;
    NSString *tempFileName = [tempPath lastPathComponent];
    [self saveTaskTempWithName:tempFileName url:url];
}

+ (void)removeTaskWithUrl:(NSString *)url {
    if (![url isNonEmpty]) return;
    url = [url stringFromMD5];
    [self removeTaskTempWithUrl:url];
}

+ (void)saveResumeData:(NSData *)resumeData url:(NSString *)url {
    if (!resumeData || resumeData.length < 1 || ![url isNonEmpty]) return;
    url = [url stringFromMD5];
    
    dispatch_barrier_async(_resumeDataQueue, ^{
        NSMutableDictionary *resumeMap = [[DXCache fetchObjectAtDocumentPathWithkey:DXDOWNLOAD_RESUME_DATA_MAP] mutableCopy];
        if (!resumeMap) resumeMap = [NSMutableDictionary new];
        [resumeMap setValue:resumeData forKey:url];
        [DXCache storeObjectAtDocumentPathWithkey:DXDOWNLOAD_RESUME_DATA_MAP object:resumeMap];
    });
}

+ (NSData *)getResumeDataWithUrl:(NSString *)url {
    if (![url isNonEmpty]) return nil;
    NSString *mdURL = [url stringFromMD5];
    __block NSData *resumeData;
    dispatch_sync(_resumeDataQueue, ^{
        NSMutableDictionary *resumeMap = [[DXCache fetchObjectAtDocumentPathWithkey:DXDOWNLOAD_RESUME_DATA_MAP] mutableCopy];
        resumeData = resumeMap[mdURL];
        if (!resumeData) {
            NSString *tempFilePath = [self getTaskTempPathWithUrl:mdURL];
            if (tempFilePath) resumeData = [self getResumeDataWithFilePath:tempFilePath url:url];
            if (!tempFilePath || !resumeData) [self removeTaskTempWithUrl:mdURL];
        }
    });
    return resumeData;
}

+ (void)removeResumeDataWithUrl:(NSString *)url {
    if (![url isNonEmpty]) return;
    url = [url stringFromMD5];
    dispatch_barrier_async(_resumeDataQueue, ^{
        NSMutableDictionary *resumeMap = [[DXCache fetchObjectAtDocumentPathWithkey:DXDOWNLOAD_RESUME_DATA_MAP] mutableCopy];
        if (!resumeMap) resumeMap = [NSMutableDictionary new];
        [resumeMap removeObjectForKey:url];
        [DXCache storeObjectAtDocumentPathWithkey:DXDOWNLOAD_RESUME_DATA_MAP object:resumeMap];
    });
}

+ (void)saveTaskTempWithName:(NSString *)name url:(NSString *)url { //url 已经md5 加密
    dispatch_barrier_async(_tempFileQueue, ^{
        NSMutableDictionary *taskTempMap = [[DXCache fetchObjectAtDocumentPathWithkey:DXDOWNLOAD_TASK_TEMP_MAP] mutableCopy];
        if (!taskTempMap) taskTempMap = [NSMutableDictionary new];
        [taskTempMap setValue:name forKey:url];
        [DXCache storeObjectAtDocumentPathWithkey:DXDOWNLOAD_TASK_TEMP_MAP object:taskTempMap];
    });
}

+ (NSString *)getTaskTempPathWithUrl:(NSString *)url { //url 已经md5 加密
    __block NSString *path;
    dispatch_sync(_tempFileQueue, ^{
        NSMutableDictionary *taskTempMap = [[DXCache fetchObjectAtDocumentPathWithkey:DXDOWNLOAD_TASK_TEMP_MAP] mutableCopy];
        NSString *fileName = taskTempMap[url];
        if (fileName) path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    });
    return path;
}

+ (void)removeTaskTempWithUrl:(NSString *)url { //url 已经md5 加密
    if (!url || url.length < 1) return;
    dispatch_barrier_async(_tempFileQueue, ^{
        NSMutableDictionary *taskTempMap = [[DXCache fetchObjectAtDocumentPathWithkey:DXDOWNLOAD_TASK_TEMP_MAP] mutableCopy];
        [taskTempMap removeObjectForKey:url];
        [DXCache storeObjectAtDocumentPathWithkey:DXDOWNLOAD_TASK_TEMP_MAP object:taskTempMap];
    });
}

+ (BOOL)isDownlongdingWithUrl:(NSString *)url {
    if (!url || url.length < 1) return NO;
    return [_downloadingList containsObject:[url stringFromMD5]];
}

+ (void)saveDownloadingWithUrl:(NSString *)url {
    if (!url || url.length < 1) return;
    [_downloadingList addObject:[url stringFromMD5]];
}

+ (void)removeDownloadingWithUrl:(NSString *)url {
    if (!url || url.length < 1) return;
    [_downloadingList removeObject:[url stringFromMD5]];
}

+ (void)saveDownloadCompletion:(DXDownloadManagerCompletion)completion url:(NSString *)url {
    if (!completion || !url || url.length < 1) return;
    url = [url stringFromMD5];
    dispatch_barrier_async(_downloadComsQueue, ^{
        NSMutableArray *completions = [_downloadCompletionList[url] mutableCopy];
        if (!completions) completions = [NSMutableArray new];
        [completions addObject:completion];
        [_downloadCompletionList setObject:completions forKey:url];
    });
}

+ (void)removeDownloadCompletionWithUrl:(NSString *)url {
    if (!url || url.length < 1) return;
    dispatch_barrier_async(_downloadComsQueue, ^{
        [_downloadCompletionList removeObjectForKey:[url stringFromMD5]];
    });
}

+ (NSData *)getResumeDataWithFilePath:(NSString *)tempFilePath url:(NSString *)url {
    NSData *resumeData;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:tempFilePath]) {
        NSDictionary *tempFileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:tempFilePath error:nil ];
        unsigned long long fileSize = [tempFileAttr[NSFileSize] unsignedLongLongValue];
        
        if (fileSize > 0) {
            NSMutableDictionary *fakeResumeData = [NSMutableDictionary dictionary];
            
            NSMutableURLRequest *newResumeRequest =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            NSString *bytesStr =[NSString stringWithFormat:@"bytes=%llu-",fileSize];
            [newResumeRequest addValue:bytesStr forHTTPHeaderField:@"Range"];
            
            NSData *newResumeData =[NSKeyedArchiver archivedDataWithRootObject:newResumeRequest];
            [fakeResumeData setObject:newResumeData forKey:@"NSURLSessionResumeCurrentRequest"];
            [fakeResumeData setObject:url forKey:@"NSURLSessionDownloadURL"];
            [fakeResumeData setObject:@(fileSize) forKey:@"NSURLSessionResumeBytesReceived"];
            [fakeResumeData setObject:[tempFilePath lastPathComponent] forKey:@"NSURLSessionResumeInfoTempFileName"]; // iOS9以下 需要路径
            
            resumeData = [NSPropertyListSerialization dataWithPropertyList:fakeResumeData format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
        }
    }
    return resumeData;
}

@end
