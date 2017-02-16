//
//  CSDownloadManager.m
//  CSKit
//
//  Created by song on 16/5/30.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "CSDownloadManager.h"
#import "CSDownloadOperation.h"
#import "CSKitMacro.h"

@interface CSDownloadManager ()
@property(nonatomic, strong)CSDownloader *downloader;
@end

@implementation CSDownloadManager

#pragma mark - life cycle
- (void)onServiceInit {
    _downloader = GET_SERVICE(CSDownloader);
    _downloadFileCache = [CSDownloadCache defaultCache];
}

#pragma mark - download
- (void)downloadWithURL:(NSURL *)url
               progress:(CSDownloaderProgressBlock)progress
               complete:(CSDownloaderCompletedBlock)completeBlock {
    [self downloadWithURL:url
                  options:0
                 progress:progress
                 complete:completeBlock];
}

- (void)downloadWithURL:(NSURL *)url
                options:(CSDownloadMgrOptions)options
               progress:(CSDownloaderProgressBlock)progress
               complete:(CSDownloaderCompletedBlock)completeBlock {
    [self downloadWithURL:url
          destinationPath:nil
                  options:options
                 progress:progress
                 complete:completeBlock];
}

- (void)downloadWithURL:(NSURL *)url
        destinationPath:(NSString *)destinationPath
               progress:(CSDownloaderProgressBlock)progress
               complete:(CSDownloaderCompletedBlock)completeBlock {
    [self downloadWithURL:url
          destinationPath:destinationPath
                  options:0
                 progress:progress
                 complete:completeBlock];
}

- (void)downloadWithURL:(NSURL *)url
        destinationPath:(NSString *)destinationPath
                options:(CSDownloadMgrOptions)options
               progress:(CSDownloaderProgressBlock)progress
               complete:(CSDownloaderCompletedBlock)completeBlock {
    [self downloadWithURL:url destinationPath:destinationPath hashCode:nil options:options progress:progress complete:completeBlock];
}

- (void)downloadWithURL:(NSURL *)url
        destinationPath:(NSString *)destinationPath
               hashCode:(NSString*)hashCode
                options:(CSDownloadMgrOptions)options
               progress:(CSDownloaderProgressBlock)progress
               complete:(CSDownloaderCompletedBlock)completeBlock {
    
    NSString *filePath = nil;
    if (!CSEmptyString(destinationPath)) {
        filePath = destinationPath;
    } else {
        filePath =  [self.downloadFileCache filePathForURL:url];
    }
    
    if (!(options & CSDownloadMgrRefreshCached) && filePath) {
        BOOL complete = YES;
        if (!CSEmptyString(hashCode)) {
            if (![hashCode isEqualToString:[CSDownloader SHA256HashCodeWithFilePath:filePath]]) {
                complete = NO;
                [self.downloadFileCache deleteFileForURL:url]; //hashcode验证不通过，直接删掉
            }
            
        }
        
        if (complete) {
            if (completeBlock) {
                completeBlock(filePath, nil, YES);
            }
            return;
        }
    }
    
    if ([url.host isEqualToString:@"localhost"]) {
        if (completeBlock) {
            NSError *error = [NSError errorWithDomain:@"CSDownloadManager" code:2 userInfo:nil];
            completeBlock(nil, error, YES);
        }
        return;
    }
    
    if (options & CSDownloadMgrOnlyUseCache) { //走到这了，说明没有缓存
        if (completeBlock) {
            NSError *error = [NSError errorWithDomain:@"CSDownloadManager" code:1 userInfo:nil];
            completeBlock(nil, error, YES);
        }
        progress = nil;
        completeBlock = nil; //回调置空
    }
    
    //网络状况,由downloader自己去处理
    CSDownloadOperation* operation = [_downloader downloadWithURL:url options:(options & CSDownloadMgrAnyNetwork)? CSDownloaderAnyNetwork: 0 progress:progress complete:completeBlock];
    
    if (!CSEmptyString(hashCode)) {
        operation.model.sha256HashCode = hashCode;
    }
}
@end
