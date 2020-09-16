//
//  DXCache.m
//  DownLoad
//
//  Created by Jackdx on 09/15/2020.
//  Copyright (c) 2020 Jackdx. All rights reserved.
//

#import "DXCache.h"

static DXCache *_cache;

@implementation DXCache

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cache = [[DXCache alloc] initWithName:@"DXCache"];
    });
}

+ (id)fetchObjectAtDocumentPathWithkey:(NSString *)key {
    NSAssert([self cacheIsNonEmpty:key], @"key不能为空");
    if (![self cacheIsNonEmpty:key]) {
        return nil;
    }
    
    return [_cache objectForKey:key];
}

+ (void)storeObjectAtDocumentPathWithkey:(NSString *)key object:(id <NSCoding>)object {
    NSAssert([self cacheIsNonEmpty:key], @"key不能为空");
    if ([self cacheIsNonEmpty:key]) {
        [_cache setObject:object forKey:key];
    }
}

+ (BOOL)cacheIsNonEmpty:(NSString *)key {
    NSMutableCharacterSet *emptyStringSet = [[NSMutableCharacterSet alloc] init];
    [emptyStringSet formUnionWithCharacterSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [emptyStringSet formUnionWithCharacterSet: [NSCharacterSet characterSetWithCharactersInString: @"　"]];
    if ([key length] == 0) {
        return NO;
    }
    NSString* str = [key stringByTrimmingCharactersInSet:emptyStringSet];
    return [str length] > 0;
}
@end
