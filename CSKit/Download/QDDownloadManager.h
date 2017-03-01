//
//  QDDownloadManager.h
//  CSKit
//
//  Created by song on 16/5/30.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDServiceCenter.h"
#import "QDDownloader.h"
#import "QDDownloadCache.h"

typedef NS_OPTIONS(NSUInteger,  QDDownloadMgrOptions) {
    /**
     *  不读缓存，默认读缓存
     */
    QDDownloadMgrRefreshCached = 1 << 1,
    /**
     *  只读缓存，无缓存继续下载，但不回调
     */
    QDDownloadMgrOnlyUseCache = 1 << 2,
    /**
     *  默认文件下载仅wifi条件才行
     */
    QDDownloadMgrAnyNetwork = 1 << 3,
};

/**
 *  管理下载任务的类
 */
@interface QDDownloadManager : QDService<QDService>

@property(nonatomic, strong)id<QDDownloadCacheProtocol> downloadFileCache;
/**
 *  download method with progress
 *
 *  @param url             文件的URL
 *  @param destinationPath 目标存储路径，传递绝对路径，默认采用YYCache进行缓存，仅存文件不存内存，默认大小200m，1000个文件，可以在QDDownloadCache设置
 *  @param options         网络下载的设定
 *  @param hashCode        64位的sha1验证
 *  @param progress        下载进度的百分比
 *  @param completeBlock         成功的回调
 */
- (void)downloadWithURL:(NSURL *)url
        destinationPath:(NSString *)destinationPath
               hashCode:(NSString*)hashCode
                options:(QDDownloadMgrOptions)options
               progress:(QDDownloaderProgressBlock)progress
               complete:(QDDownloaderCompletedBlock)completeBlock;

- (void)downloadWithURL:(NSURL *)url
        destinationPath:(NSString *)destinationPath
                options:(QDDownloadMgrOptions)options
               progress:(QDDownloaderProgressBlock)progress
               complete:(QDDownloaderCompletedBlock)completeBlock;

//下面都是封装方法
- (void)downloadWithURL:(NSURL *)url
               progress:(QDDownloaderProgressBlock)progress
               complete:(QDDownloaderCompletedBlock)completeBlock;

- (void)downloadWithURL:(NSURL *)url
                options:(QDDownloadMgrOptions)options
               progress:(QDDownloaderProgressBlock)progress
               complete:(QDDownloaderCompletedBlock)completeBlock;

- (void)downloadWithURL:(NSURL *)url
        destinationPath:(NSString *)destinationPath
               progress:(QDDownloaderProgressBlock)progress
               complete:(QDDownloaderCompletedBlock)completeBlock;
@end
