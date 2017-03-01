//
//  QDDownloadCache.m
//  QDKitDemo
//
//  Created by song on 2017/2/15.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDDownloadCache.h"
#import "CSYYCache/YYDiskFileCache.h"
#import <CommonCrypto/CommonDigest.h>

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
    return [NSString stringWithFormat:@"%@.%@", [self md5Hash:key], ext];
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


- (NSString *)md5Hash:(NSString*)str {
    if (CSEmptyString(str)) {
        return @"";
    }
    
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (int)[data length], result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}
@end
