//
//  CSDownloadManager.h
//  CSKit
//
//  Created by song on 16/5/30.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "CServiceCenter.h"
#import "CSDownloader.h"

typedef NS_OPTIONS(NSUInteger,  CSDownloadMgrOptions) {
    /**
     * 缓存保持，默认会有一个缓存清理机制，如果启用了缓存保持，该文件的清理和删除归掉用方自己管理。 ---缓存保持则destinationPath不能为空
     */
    CSDownloadMgrCachePersist = 1 << 1,
    /**
     *  不读缓存，默认读缓存
     */
    CSDownloadMgrRefreshCached = 1 << 2,
    /**
     *  只读缓存，无缓存继续下载，但不回调
     */
    CSDownloadMgrOnlyUseCache = 1 << 3,
    /**
     *  默认文件下载仅wifi条件才行
     */
    CSDownloadMgrAnyNetwork = 1 << 4,
};

/**
 *  管理下载任务的类
 */
@interface CSDownloadManager : CService<CService>

/**
 *  download method with progress
 *
 *  @param url             文件的URL
 *  @param destinationPath 目标存储路径,传递绝对路径,默认是 ../Library/bundleName/downloadCache
 *  @param options         网络下载的设定
 *  @param hashCode        64位的sha1验证
 *  @param progress        下载进度的百分比
 *  @param completeBlock         成功的回调
 */
- (void)downloadWithURL:(NSURL *)url
        destinationPath:(NSString *)destinationPath
               hashCode:(NSString*)hashCode
                options:(CSDownloadMgrOptions)options
               progress:(CSDownloaderProgressBlock)progress
               complete:(CSDownloaderCompletedBlock)completeBlock;

- (void)downloadWithURL:(NSURL *)url
        destinationPath:(NSString *)destinationPath
                options:(CSDownloadMgrOptions)options
               progress:(CSDownloaderProgressBlock)progress
               complete:(CSDownloaderCompletedBlock)completeBlock;



- (BOOL)localExistsForURL:(NSURL *)URL;
- (void)localFileForURL:(NSURL *)URL complete:(void(^) (BOOL exsit, NSURL* localPathURL)) completeBlock;

- (void)clearAllFile;
- (void)clearAllFileWithCompletion:(void(^)())completeBlock;
- (void)removeFileWithURL:(NSURL *)url;

//下面都是封装方法
- (void)downloadWithURL:(NSURL *)url
               progress:(CSDownloaderProgressBlock)progress
               complete:(CSDownloaderCompletedBlock)completeBlock;

- (void)downloadWithURL:(NSURL *)url
                options:(CSDownloadMgrOptions)options
               progress:(CSDownloaderProgressBlock)progress
               complete:(CSDownloaderCompletedBlock)completeBlock;

- (void)downloadWithURL:(NSURL *)url
        destinationPath:(NSString *)destinationPath
               progress:(CSDownloaderProgressBlock)progress
               complete:(CSDownloaderCompletedBlock)completeBlock;
@end
