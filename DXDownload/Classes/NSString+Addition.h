//
//  NSString+Addition.h
//  DownLoad
//
//  Created by Jackdx on 09/15/2020.
//  Copyright (c) 2020 Jackdx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Addition)

+ (NSString *)documentPath;
- (BOOL)isNonEmpty;
- (NSString *)stringFromMD5;

@end

NS_ASSUME_NONNULL_END
