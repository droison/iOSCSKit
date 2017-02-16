//
//  CSDownloader.h
//  CSKit
//
//  Created by song on 16/5/30.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "CSDownloadModel.h"
#import "CServiceCenter.h"

typedef NS_OPTIONS(NSUInteger, CSDownloaderOptions) {
    /**
     *  默认文件下载仅wifi条件才行
     */
    CSDownloaderAnyNetwork = 1 << 0,
};

@class CSDownloadOperation;

@interface CSDownloader : CService<CService>

/**
 *  下载启动类
 *
 *  @param url             下载的url，相同的url会被合并一起下载
 *  @param options 下载参数，当前仅支持是否wifi
 *  @param progress 下载进度的回调
 *  @param completeBlock 下载结束的回调，成功或者失败
 *
 *  @return CSDownloadOperation
 */
- (CSDownloadOperation*) downloadWithURL:(NSURL *)url
                                    options:(CSDownloaderOptions)options
                                   progress:(CSDownloaderProgressBlock)progress
                                   complete:(CSDownloaderCompletedBlock)completeBlock;

/**
 * Sets the download queue suspension state
 */
- (void)setSuspended:(BOOL)suspended;

/**
 * Cancels all download operations in the queue
 */
- (void)cancelAllDownloads;

- (void)cancelDownload : (NSURL*) URL;

+ (NSString*)SHA256HashCodeWithFilePath:(NSString*)filePath;
@end
