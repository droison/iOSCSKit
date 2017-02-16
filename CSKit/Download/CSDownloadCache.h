//
//  CSDownloadCache.h
//  CSKitDemo
//
//  Created by song on 2017/2/15.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "CServiceCenter.h"

@protocol CSDownloadCacheProtocol <NSObject>
@property NSUInteger maxFileCount;
@property NSUInteger maxFileSize;

- (BOOL)containsFileForURL:(NSURL *)url;

- (NSString*)filePathForURL:(NSURL *)url; //select

- (void)addFile:(NSString*)filePath forURL:(NSURL *)url; //insert and update

- (void)deleteFileForURL:(NSURL *)url; //delete

- (void)clearAllFiles;

@end

@interface CSDownloadCache : CService<CService, CSDownloadCacheProtocol>

+ (CSDownloadCache*) defaultCache;

@end
