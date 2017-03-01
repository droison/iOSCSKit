//
//  QDDownloader.h
//  QDKit
//
//  Created by song on 16/5/30.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDDownloadModel.h"
#import "QDServiceCenter.h"

typedef NS_OPTIONS(NSUInteger, QDDownloaderOptions) {
    /**
     *  默认文件下载仅wifi条件才行
     */
    QDDownloaderAnyNetwork = 1 << 0,
};

@class QDDownloadOperation;

@interface QDDownloader : QDService<QDService>

/**
 *  下载启动类
 *
 *  @param url             下载的url，相同的url会被合并一起下载
 *  @param options 下载参数，当前仅支持是否wifi
 *  @param progress 下载进度的回调
 *  @param completeBlock 下载结束的回调，成功或者失败
 *
 *  @return QDDownloadOperation
 */
- (QDDownloadOperation*) downloadWithURL:(NSURL *)url
                                 options:(QDDownloaderOptions)options
                                progress:(QDDownloaderProgressBlock)progress
                                complete:(QDDownloaderCompletedBlock)completeBlock;

/**
 * Sets the download queue suspension state
 */
- (void)setSuspended:(BOOL)suspended;

/**
 * Cancels all download operations in the queue
 */
- (void)cancelAllDownloads;

- (void)cancelDownload:(NSURL*) URL;

+ (NSString*)SHA256HashCodeWithFilePath:(NSString*)filePath;
@end
