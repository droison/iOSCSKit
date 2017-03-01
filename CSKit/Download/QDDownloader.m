//
//  QDDownloader.m
//  CSKit
//
//  Created by song on 16/5/30.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDDownloader.h"
#import "QDDownloadOperation.h"
#import "QDNetworkReachabilityManager.h"
#import "QDBus.h"
#import <CommonCrypto/CommonDigest.h>
#import "QDDownloadCache.h"

typedef void(^QDDownloaderCreateBlock)(QDDownloadModel* model, BOOL added);

#define MaxConcurrentCount 3
static NSString * const kQDDownloadSessionIdentifier = @"xyz.chaisong.fileDownload.sessionIdentifier";
static NSString * const kQDDownloaderLockName = @"xyz.chaisong.downloader.lock";

@interface QDDownloader () <NSURLSessionDownloadDelegate, CSNetWorkChangeExt> {
    NSMutableDictionary *_executings;
    NSMutableDictionary *_waitings;
    NSMutableArray *_waitingURLs;
}

@property (nonatomic, strong) NSURLSession *session;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

@end

@implementation QDDownloader


- (instancetype)init {
    if (self = [super init]) {
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = kQDDownloaderLockName;
        
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = MaxConcurrentCount;

        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kQDDownloadSessionIdentifier];
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:self.operationQueue];
        _waitings = [NSMutableDictionary dictionary];
        _executings = [NSMutableDictionary dictionaryWithCapacity:MaxConcurrentCount];
        _waitingURLs = [NSMutableArray array];
    }
    return self;
}

- (void) onServiceInit {
    REGISTER_OBSERVER(CSNetWorkChangeExt, self);
    
}
- (void)onServiceTerminate {
    UNREGISTER_ALL_OBSERVER(self);
}

//启动下载时候会遍历所有已经运行的和未运行的请求，只要相同的url有1个是QDDownloaderAnyNetwork，则所有的都是无视网络环境
- (QDDownloadOperation* ) downloadWithURL:(NSURL *)url
                                     options:(QDDownloaderOptions)options
                                    progress:(QDDownloaderProgressBlock)progressBlock
                                    complete:(QDDownloaderCompletedBlock)completedBlock {
    __block QDDownloadOperation *operation;
    __weak __typeof(self)wself = self;
    
    [self addProgressCallback:progressBlock completedBlock:completedBlock forURL:url createCallback:^(QDDownloadModel *model, BOOL added) {
        if (options & QDDownloaderAnyNetwork) {
            model.requestOnAnyNetWork = YES; //有一个请求无视网络，那就无视网络环境
        }
        if (added) {
            model.operation = [[QDDownloadOperation alloc] initWithModel:model session:wself.session];
        }
        [wself flushWaitingQueue];
        operation = model.operation;
    }];
    return operation;
}

- (void)setSuspended:(BOOL)suspended {
    [self.lock lock];
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:MaxConcurrentCount];
    [_executings enumerateKeysAndObjectsUsingBlock:^(NSURL*  _Nonnull key, QDDownloadModel*  _Nonnull model, BOOL * _Nonnull stop) {
        if (model.operation) {
            if (suspended) {
                [model.operation.downloadTask suspend];
                [array addObject:model];
            } else {
                [model.operation.downloadTask resume];
            }
        }
    }];
    if (array.count > 0) {
        for (QDDownloadModel* model in array) { //把暂停的request放回去
            [_executings removeObjectForKey:model.URL];
            _waitings[model.URL] = model;
            [_waitingURLs addObject:model.URL];
        }
    }
    if (!suspended) { //重新启动 需要去启动下载
        [self flushWaitingQueue];
    }
    [self.lock unlock];
}

- (void)suspendOnlyWiFiRequest {
    
    [self.lock lock];
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:MaxConcurrentCount];
    [_executings enumerateKeysAndObjectsUsingBlock:^(NSURL*  _Nonnull key, QDDownloadModel*  _Nonnull model, BOOL * _Nonnull stop) {
        if (model.operation && !model.requestOnAnyNetWork) {
            [model.operation.downloadTask suspend];
            [array addObject:model];
        }
    }];
    if (array.count > 0) {
        for (QDDownloadModel* model in array) { //把暂停的request放回去
            [_executings removeObjectForKey:model.URL];
            _waitings[model.URL] = model;
            [_waitingURLs addObject:model.URL];
        }
        [self flushWaitingQueue];//有删除才有必要新增
    }
    
    [self.lock unlock];
}


- (void)cancelAllDownloads {
    [self.lock lock];
    [_executings enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, QDDownloadModel*  _Nonnull model, BOOL * _Nonnull stop) {
        if (model.operation) {
            [model.operation.downloadTask cancel];
        }
    }];
    [_waitingURLs removeAllObjects];
    [_waitings removeAllObjects];
    [_executings removeAllObjects];
    [self.lock unlock];
}

- (void)cancelDownload:(NSURL*) URL {
    [self.lock lock];
    QDDownloadModel* model = _executings[URL];
    if (!model) {
        model = _waitings[URL];
    }
    if (model) {
        [model.operation cancel];
    }
    [self.lock unlock];
}

- (void)addProgressCallback:(QDDownloaderProgressBlock)progressBlock completedBlock:(QDDownloaderCompletedBlock)completedBlock forURL:(NSURL *)url createCallback:(QDDownloaderCreateBlock)createCallback {
    // The URL will be used as the key to the callbacks dictionary so it cannot be nil. If it is nil immediately call the completed block with no image or data.
    if (url == nil) {
        if (completedBlock != nil) {
            completedBlock(nil, nil, NO);
        }
        return;
    }
    
    [self.lock lock];
    BOOL first = NO;
    
    QDDownloadModel* model = _executings[url];
    if (model) {
        if (progressBlock) {
            [model.progressBlocks addObject:progressBlock];
        }
        if (completedBlock) {
            [model.completeBlocks addObject:completedBlock];
        }
    } else {
        model = _waitings[url];
        if (!model) {
            model = [[QDDownloadModel alloc] init];
            model.URL = url;
            _waitings[url] = model;
            [_waitingURLs addObject:url];
            first = YES;
        }
        if (progressBlock) {
            [model.progressBlocks addObject:progressBlock];
        }
        if (completedBlock) {
            [model.completeBlocks addObject:completedBlock];
        }
    }
    [self.lock unlock];
    
    createCallback(model, first);
}

- (void) flushWaitingQueue {
    if (_executings.count < MaxConcurrentCount && _waitingURLs.count > 0) {
        BOOL findAvailUrl = NO;
        if (GET_SERVICE(QDNetworkReachabilityManager).reachableViaWiFi) { //wifi
            NSURL* url = [[_waitingURLs firstObject] copy];
            QDDownloadModel* model = [_waitings objectForKey:url];
            if (model) {
                if (!model.operation.isCancel) {
                    _executings[url] = model;
                    [model.operation start];
                }
                [_waitingURLs removeObject:url];
                [_waitings removeObjectForKey:url];
            }
            findAvailUrl = YES;
        } else if (GET_SERVICE(QDNetworkReachabilityManager).reachableViaWWAN) { //这里要判断下载了
            NSURL* url;
            QDDownloadModel* model;
            
            NSMutableArray* needFailURLs = [NSMutableArray arrayWithCapacity:_waitings.count];
            
            for (url in _waitingURLs) {
                model = [_waitings objectForKey:url];
                if (model) {
                    if (model.requestOnAnyNetWork) {
                        findAvailUrl = YES;
                        break;
                    } else {
                        NSError* resultError = [NSError errorWithDomain:@"QDDownloader" code:3 userInfo:@{@"msg":@"网络不支持", @"当前网络":@"Cellular", @"需要网络":@"WiFi"}];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            for (QDDownloaderCompletedBlock completeBlock in model.completeBlocks) {
                                completeBlock(nil, resultError, NO);
                            }
                        });
                        [needFailURLs addObject:url];
                    }
                }
            }
            
            [_waitingURLs removeObjectsInArray:needFailURLs];
            [_waitings removeObjectsForKeys:needFailURLs];
            
            if (findAvailUrl) {
                if (!model.operation.isCancel) {
                    _executings[url] = model;
                    [model.operation start];
                }
                [_waitingURLs removeObject:url];
                [_waitings removeObjectForKey:url];
            }
        } else { //无网络
            NSURL* url;
            QDDownloadModel* model;
            for (url in _waitingURLs) {
                model = [_waitings objectForKey:url];
                if (model) {
                    NSError* resultError = [NSError errorWithDomain:@"QDDownloader" code:3 userInfo:@{@"msg":@"网络不支持", @"当前网络":@"无网络", @"需要网络":model.requestOnAnyNetWork? @"AnyNetwork": @"WiFi"}];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        for (QDDownloaderCompletedBlock completeBlock in model.completeBlocks) {
                            completeBlock(nil, resultError, NO);
                        }
                    });
                }
            }
            [_waitingURLs removeAllObjects];
            [_waitings removeAllObjects];
        }
        
        if (findAvailUrl) {
            [self flushWaitingQueue];
        }
    }
}

- (void)changeStatusFrom:(QDNetworkReachabilityStatus)last to:(QDNetworkReachabilityStatus)current {
    if (current == last) {
        return;
    }
    if (current != QDNetworkReachabilityStatusReachableViaWiFi && current != QDNetworkReachabilityStatusReachableViaWWAN) { //无网络，全暂停
        [self setSuspended:YES];
        return;
    }
    if (current == QDNetworkReachabilityStatusReachableViaWiFi) { //当前是wifi，启动新请求
        [self setSuspended:NO];
    } else { //否则，暂停所有wifi请求
        [self suspendOnlyWiFiRequest];
    }
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    //本地的文件路径，使用fileURLWithPath:来创建
    [self.lock lock];
    QDDownloadModel* model = _executings[downloadTask.originalRequest.URL];
    [self.lock unlock];
    
    if (model && !model.localPath) {
        NSString* hashCode = model.sha256HashCode;
        
        if (!CSEmptyString(hashCode) && ![hashCode isEqualToString:[QDDownloader SHA256HashCodeWithURL:model.URL]]) {
            model.hashCodeVerifyFail = YES;
            return;
        }
        [[QDDownloadCache defaultCache] addFile:location.path forURL:model.URL];
        model.localPath = [[QDDownloadCache defaultCache] filePathForURL:model.URL];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    [self.lock lock];
    QDDownloadModel *model = [_executings[task.originalRequest.URL] copy];
    if (task.state == NSURLSessionTaskStateCanceling || task.state == NSURLSessionTaskStateCompleted) {
        [_executings removeObjectForKey:task.originalRequest.URL];
    }
    [self flushWaitingQueue];
    [self.lock unlock];
    
    if (model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* localPath = model.localPath;
            if (error == nil && task.state == NSURLSessionTaskStateCompleted) { //下载成功
                if (!CSEmptyString(model.sha256HashCode) && model.hashCodeVerifyFail) { //验证失败
                    NSError* resultError = [NSError errorWithDomain:@"QDDownloader" code:4 userInfo:@{@"msg":@"hashcode验证失败", @"url":model.URL, @"hashcode":model.sha256HashCode}];
                    for (QDDownloaderCompletedBlock completeBlock in model.completeBlocks) {
                        completeBlock(localPath, resultError, NO);
                    }
                    return;
                }
            }
            
            for (QDDownloaderCompletedBlock completeBlock in model.completeBlocks) {
                completeBlock(localPath, error, task.state == NSURLSessionTaskStateCompleted);
            }
        });
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    [self.lock lock];
    QDDownloadModel *model = [_executings[downloadTask.originalRequest.URL] copy];
    [self.lock unlock];
    
    if (model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (QDDownloaderProgressBlock progressBlock in model.progressBlocks) {
                progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
            }
        });
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    [self.lock lock];
    QDDownloadModel *model = [_executings[downloadTask.originalRequest.URL] copy];
    [self.lock unlock];
    
    if (model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (QDDownloaderProgressBlock progressBlock in model.progressBlocks) {
                progressBlock(fileOffset, expectedTotalBytes);
            }
        });
    }
}

#pragma mark - Util
//所有的下载完成都走这里
+ (NSString*)SHA256HashCodeWithURL:(NSURL*)URL {
    NSData* dataIn = [NSData dataWithContentsOfURL:URL];
    return [QDDownloader SHA256HashCode:dataIn];
}

//所有的本地读取都走这里
+ (NSString*)SHA256HashCodeWithFilePath:(NSString*)filePath {
    NSData* dataIn = [NSData dataWithContentsOfFile:filePath];
    return [QDDownloader SHA256HashCode:dataIn];
}

+ (NSString*)SHA256HashCode:(NSData*)dataIn {
    if (dataIn == nil) {
        return nil;
    }
    uint32_t length = (uint32_t) dataIn.length;
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(dataIn.bytes, length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    return hash;
}

@end
