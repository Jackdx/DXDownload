#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "DXCache.h"
#import "DXDownloadManager.h"
#import "NSString+Addition.h"

FOUNDATION_EXPORT double DXDownloadVersionNumber;
FOUNDATION_EXPORT const unsigned char DXDownloadVersionString[];

