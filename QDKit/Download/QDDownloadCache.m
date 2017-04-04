//
//  QDDownloadCache.m
//  QDKitDemo
//
//  Created by song on 2017/2/15.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDDownloadCache.h"
#import "CSYYCache/YYDiskFileCache.h"
#import "QDUtils.h"

@implementation QDDownloadCache {
    YYDiskFileCache* _cache;
}
@synthesize maxFileSize = _maxFileSize;
@synthesize maxFileCount = _maxFileCount;

+(QDDownloadCache *)defaultCache {
    return GET_SERVICE(QDDownloadCache);
}

-(void)onServiceInit {
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [cacheFolder stringByAppendingPathComponent:@"QDDownloadCache"];
    self->_cache = [[YYDiskFileCache alloc] initWithPath:path]; //以20K为分界  20k以下用sql 20k以上为文件
    self.maxFileSize = 200*1024*1024;
    self.maxFileCount = 1000;
    __weak typeof(self) weakSelf = self;
    self->_cache.customFileNameBlock = ^NSString*(NSString* key) {
        return [weakSelf fileNameFromCacheKey:key];
    };
}

-(NSString*)cacheKeyFromURL:(NSURL*)url {
    return url.absoluteString;
}

-(NSString*)fileNameFromCacheKey:(NSString*)key {
    NSString* ext = key.pathExtension;
    if (CSEmptyString(ext)) {
        ext = @"unknown";
    }
    return [NSString stringWithFormat:@"%@.%@", [QDUtils md5Hash:key], ext];
}

-(void)setMaxFileSize:(NSUInteger)maxFileSize {
    if (maxFileSize != _maxFileSize) {
        _maxFileSize = maxFileSize;
        [self->_cache setCostLimit:_maxFileSize];
    }
}

-(void)setMaxFileCount:(NSUInteger)maxFileCount {
    if (maxFileCount != _maxFileCount) {
        _maxFileCount = maxFileCount;
        [self->_cache setCountLimit:_maxFileCount];
    }
}

- (BOOL)containsFileForURL:(NSURL *)url {
    NSString* key = [self cacheKeyFromURL:url];
    return [self->_cache containsFileForKey:key];
}

- (NSString*)filePathForURL:(NSURL *)url {
    NSString* key = [self cacheKeyFromURL:url];
    return [self->_cache filePathForKey:key];
}

- (void)addFile:(NSString*)filePath forURL:(NSURL *)url {
    NSString* key = [self cacheKeyFromURL:url];
    [self->_cache addFile:filePath forKey:key];
}

- (void)deleteFileForURL:(NSURL *)url {
    NSString* key = [self cacheKeyFromURL:url];
    [self->_cache deleteFileForKey:key];
}

- (void)clearAllFiles {
    [self->_cache clearAllFiles];
}
@end
