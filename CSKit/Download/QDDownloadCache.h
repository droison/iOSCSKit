//
//  QDDownloadCache.h
//  CSKitDemo
//
//  Created by song on 2017/2/15.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDServiceCenter.h"

@protocol QDDownloadCacheProtocol <NSObject>
@property NSUInteger maxFileCount;
@property NSUInteger maxFileSize;

- (BOOL)containsFileForURL:(NSURL *)url;

- (NSString*)filePathForURL:(NSURL *)url; //select

- (void)addFile:(NSString*)filePath forURL:(NSURL *)url; //insert and update

- (void)deleteFileForURL:(NSURL *)url; //delete

- (void)clearAllFiles;

@end

@interface QDDownloadCache : QDService<QDService, QDDownloadCacheProtocol>

+ (QDDownloadCache*) defaultCache;

@end
