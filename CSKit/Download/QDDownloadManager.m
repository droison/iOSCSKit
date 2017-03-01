//
//  QDDownloadManager.m
//  CSKit
//
//  Created by song on 16/5/30.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDDownloadManager.h"
#import "QDDownloadOperation.h"
#import "CSKitMacro.h"

@interface QDDownloadManager ()
@property(nonatomic, strong)QDDownloader *downloader;
@end

@implementation QDDownloadManager

#pragma mark - life cycle
- (void)onServiceInit {
    _downloader = GET_SERVICE(QDDownloader);
    _downloadFileCache = [QDDownloadCache defaultCache];
}

#pragma mark - download
- (void)downloadWithURL:(NSURL *)url
               progress:(QDDownloaderProgressBlock)progress
               complete:(QDDownloaderCompletedBlock)completeBlock {
    [self downloadWithURL:url
                  options:0
                 progress:progress
                 complete:completeBlock];
}

- (void)downloadWithURL:(NSURL *)url
                options:(QDDownloadMgrOptions)options
               progress:(QDDownloaderProgressBlock)progress
               complete:(QDDownloaderCompletedBlock)completeBlock {
    [self downloadWithURL:url
          destinationPath:nil
                  options:options
                 progress:progress
                 complete:completeBlock];
}

- (void)downloadWithURL:(NSURL *)url
        destinationPath:(NSString *)destinationPath
               progress:(QDDownloaderProgressBlock)progress
               complete:(QDDownloaderCompletedBlock)completeBlock {
    [self downloadWithURL:url
          destinationPath:destinationPath
                  options:0
                 progress:progress
                 complete:completeBlock];
}

- (void)downloadWithURL:(NSURL *)url
        destinationPath:(NSString *)destinationPath
                options:(QDDownloadMgrOptions)options
               progress:(QDDownloaderProgressBlock)progress
               complete:(QDDownloaderCompletedBlock)completeBlock {
    [self downloadWithURL:url destinationPath:destinationPath hashCode:nil options:options progress:progress complete:completeBlock];
}

- (void)downloadWithURL:(NSURL *)url
        destinationPath:(NSString *)destinationPath
               hashCode:(NSString*)hashCode
                options:(QDDownloadMgrOptions)options
               progress:(QDDownloaderProgressBlock)progress
               complete:(QDDownloaderCompletedBlock)completeBlock {
    
    NSString *filePath = nil;
    if (!CSEmptyString(destinationPath)) {
        filePath = destinationPath;
    } else {
        filePath =  [self.downloadFileCache filePathForURL:url];
    }
    
    if (!(options & QDDownloadMgrRefreshCached) && filePath) {
        BOOL complete = YES;
        if (!CSEmptyString(hashCode)) {
            if (![hashCode isEqualToString:[QDDownloader SHA256HashCodeWithFilePath:filePath]]) {
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
            NSError *error = [NSError errorWithDomain:@"QDDownloadManager" code:2 userInfo:nil];
            completeBlock(nil, error, YES);
        }
        return;
    }
    
    if (options & QDDownloadMgrOnlyUseCache) { //走到这了，说明没有缓存
        if (completeBlock) {
            NSError *error = [NSError errorWithDomain:@"QDDownloadManager" code:1 userInfo:nil];
            completeBlock(nil, error, YES);
        }
        progress = nil;
        completeBlock = nil; //回调置空
    }
    
    //网络状况,由downloader自己去处理
    QDDownloadOperation* operation = [_downloader downloadWithURL:url options:(options & QDDownloadMgrAnyNetwork)? QDDownloaderAnyNetwork: 0 progress:progress complete:completeBlock];
    
    if (!CSEmptyString(hashCode)) {
        operation.model.sha256HashCode = hashCode;
    }
}
@end
