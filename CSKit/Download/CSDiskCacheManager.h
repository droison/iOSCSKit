//
//  CSDiskCacheManager.h
//  CSKit
//
//  Created by song on 14-6-16.
//  Copyright © 2017年 Personal. All rights reserved.
//
#if !__has_feature(nullability)
#	define nullable
#	define nonnull
#	define __nullable
#	define __nonnull
#endif

#import "CServiceCenter.h"
#import <UIKit/UIKit.h>

@interface CSDiskCacheManager : CService<CService>

// Opitionally create a different EGOCache instance with it's own cache directory
- (nonnull instancetype)initWithCacheDirectory:(NSString* __nonnull)cacheDirectory;

- (NSString* __nullable) cacheDirectory;

- (void)clearCache;
- (void)removeCacheForKey:(NSString* __nonnull)key;
- (BOOL)hasCacheForKey:(NSString* __nonnull)key;

- (NSDictionary * __nullable)jsonForUrl:(NSString * __nonnull)url withParams:(NSDictionary* __nullable)params;
- (void) setJson:(NSDictionary * __nullable)item forURL:(NSString * __nonnull)url withParams:(NSDictionary* __nullable)params;
- (void) setJson:(NSDictionary * __nullable)item forURL:(NSString * __nonnull)url withParams:(NSDictionary* __nullable)params withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (NSString * __nullable)eTagForUrl:(NSString * __nonnull)url withParams:(NSDictionary* __nullable)params;
- (void) setEtag:(NSString * __nullable)etag forURL:(NSString * __nonnull)url withParams:(NSDictionary* __nullable)params;

- (NSData* __nullable)dataForKey:(NSString* __nonnull)key;
- (void)setData:(NSData* __nonnull)data forKey:(NSString* __nonnull)key;
- (void)setData:(NSData* __nonnull)data forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (NSString* __nullable)stringForKey:(NSString* __nonnull)key;
- (void)setString:(NSString* __nonnull)aString forKey:(NSString* __nonnull)key;
- (void)setString:(NSString* __nonnull)aString forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (NSDate* __nullable)dateForKey:(NSString* __nonnull)key;
- (NSArray* __nonnull)allKeys;

- (UIImage* __nullable)imageForKey:(NSString* __nonnull)key;
- (void)setImage:(UIImage* __nonnull)anImage forKey:(NSString* __nonnull)key;
- (void)setImage:(UIImage* __nonnull)anImage forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (NSData* __nullable)plistForKey:(NSString* __nonnull)key;
- (void)setPlist:(nonnull id)plistObject forKey:(NSString* __nonnull)key;
- (void)setPlist:(nonnull id)plistObject forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (void)copyFilePath:(NSString* __nonnull)filePath asKey:(NSString* __nonnull)key;
- (void)copyFilePath:(NSString* __nonnull)filePath asKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (nullable id<NSCoding>)objectForKey:(NSString* __nonnull)key;
- (void)setObject:(nonnull id<NSCoding>)anObject forKey:(NSString* __nonnull)key;
- (void)setObject:(nonnull id<NSCoding>)anObject forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

@property(nonatomic) NSTimeInterval defaultTimeoutInterval; // Default is 7 day
@end
