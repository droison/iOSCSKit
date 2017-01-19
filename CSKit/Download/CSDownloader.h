//
//  CSDownloader.h
//  QDaily
//
//  Created by 淞 柴 on 16/5/30.
//  Copyright © 2016年 Qdaily. All rights reserved.
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
 *  @param destinationPath 存储位置，会保存在第一个存入的path，后面再存也没有用，所以completeBlock时候一定要判断下路径是不是自己想要的，如果不是，请copy出去，千万别move
 *  @param options
 *  @param progress
 *  @param completeBlock
 *
 *  @return CSDownloadOperation
 */
- (CSDownloadOperation*) downloadWithURL:(NSURL *)url
                            destinationPath:(NSString *)destinationPath
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
