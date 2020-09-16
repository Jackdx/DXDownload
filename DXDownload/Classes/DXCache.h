//
//  DXCache.h
//  DownLoad
//
//  Created by Jackdx on 09/15/2020.
//  Copyright (c) 2020 Jackdx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TMCache/TMCache.h>


NS_ASSUME_NONNULL_BEGIN

@interface DXCache : TMCache

+ (id)fetchObjectAtDocumentPathWithkey:(NSString *)key;
+ (void)storeObjectAtDocumentPathWithkey:(NSString *)key object:(id <NSCoding>)object;
@end

NS_ASSUME_NONNULL_END
