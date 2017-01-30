//
//  CSDownloader.m
//  CSKit
//
//  Created by song on 16/5/30.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "CSDownloader.h"
#import "CSDownloadOperation.h"
#import "CSNetworkReachabilityManager.h"
#import "CSBus.h"
#import <CommonCrypto/CommonDigest.h>

typedef void(^CSDownloaderCreateBlock)(CSDownloadModel* model, BOOL added);

#define MaxConcurrentCount 3
#define QFileDownloadSessionIdentifier @"xyz.chaisong.fileDownload.sessionIdentifier"
#define QFileDownloadBarrierQueue "xyz.chaisong.fileDownload.barrierQueue"

@interface CSDownloader () <NSURLSessionDownloadDelegate, CSNetWorkChangeExt> {
    NSMutableDictionary *_executings;
    NSMutableDictionary *_waitings;
    NSMutableArray *_waitingURLs;
}

@property (strong, nonatomic) dispatch_queue_t barrierQueue; //调度队列
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation CSDownloader


- (instancetype)init {
    if (self = [super init]) {
        _barrierQueue = dispatch_queue_create(QFileDownloadBarrierQueue, DISPATCH_QUEUE_CONCURRENT);;
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:QFileDownloadSessionIdentifier];
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:nil];
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

//启动下载时候会遍历所有已经运行的和未运行的请求，只要相同的url有1个是CSDownloaderAnyNetwork，则所有的都是无视网络环境
- (CSDownloadOperation* ) downloadWithURL:(NSURL *)url
                             destinationPath:(NSString *)destinationPath
                                     options:(CSDownloaderOptions)options
                                    progress:(CSDownloaderProgressBlock)progressBlock
                                    complete:(CSDownloaderCompletedBlock)completedBlock {
    __block CSDownloadOperation *operation;
    __weak __typeof(self)wself = self;
    
    [self addProgressCallback:progressBlock completedBlock:completedBlock forURL:url createCallback:^(CSDownloadModel *model, BOOL added) {
        if (options & CSDownloaderAnyNetwork) {
            model.requestOnAnyNetWork = YES; //有一个请求无视网络，那就无视网络环境
        }
        if (added) {
            model.localPath = destinationPath;
            model.operation = [[CSDownloadOperation alloc] initWithModel:model session:wself.session];
        }
        [wself flushWaitingQueue];
        operation = model.operation;
    }];
    return operation;
}

- (void)setSuspended:(BOOL)suspended {
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:MaxConcurrentCount];
    [_executings enumerateKeysAndObjectsUsingBlock:^(NSURL*  _Nonnull key, CSDownloadModel*  _Nonnull model, BOOL * _Nonnull stop) {
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
        dispatch_barrier_sync(self.barrierQueue, ^{
            for (CSDownloadModel* model in array) { //把暂停的request放回去
                [_executings removeObjectForKey:model.URL];
                _waitings[model.URL] = model;
                [_waitingURLs addObject:model.URL];
            }
        });
    }
    if (!suspended) { //重新启动 需要去启动下载
        dispatch_barrier_async(self.barrierQueue, ^{
            [self flushWaitingQueue];
        });
    }
}

- (void)suspendOnlyWiFiRequest {
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:MaxConcurrentCount];
    [_executings enumerateKeysAndObjectsUsingBlock:^(NSURL*  _Nonnull key, CSDownloadModel*  _Nonnull model, BOOL * _Nonnull stop) {
        if (model.operation && !model.requestOnAnyNetWork) {
            [model.operation.downloadTask suspend];
            [array addObject:model];
        }
    }];
    if (array.count > 0) {
        dispatch_barrier_sync(self.barrierQueue, ^{
            for (CSDownloadModel* model in array) { //把暂停的request放回去
                [_executings removeObjectForKey:model.URL];
                _waitings[model.URL] = model;
                [_waitingURLs addObject:model.URL];
            }
            [self flushWaitingQueue];//有删除才有必要新增
        });
    }
}


- (void)cancelAllDownloads {
    [_executings enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, CSDownloadModel*  _Nonnull model, BOOL * _Nonnull stop) {
        if (model.operation) {
            [model.operation.downloadTask cancel];
        }
    }];
    dispatch_barrier_sync(self.barrierQueue, ^{
        [_waitingURLs removeAllObjects];
        [_waitings removeAllObjects];
        [_executings removeAllObjects];
    });
}

- (void)cancelDownload:(NSURL*) URL {
    dispatch_barrier_sync(self.barrierQueue, ^{
        CSDownloadModel* model = _executings[URL];
        if (!model) {
            model = _waitings[URL];
        }
        if (model) {
            [model.operation cancel];
        }
    });
}

- (void)addProgressCallback:(CSDownloaderProgressBlock)progressBlock completedBlock:(CSDownloaderCompletedBlock)completedBlock forURL:(NSURL *)url createCallback:(CSDownloaderCreateBlock)createCallback {
    // The URL will be used as the key to the callbacks dictionary so it cannot be nil. If it is nil immediately call the completed block with no image or data.
    if (url == nil) {
        if (completedBlock != nil) {
            completedBlock(nil, nil, NO);
        }
        return;
    }
    
    dispatch_barrier_sync(self.barrierQueue, ^{
        BOOL first = NO;
        
        CSDownloadModel* model = _executings[url];
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
                model = [[CSDownloadModel alloc] init];
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
        createCallback(model, first);
    });
}

- (void) flushWaitingQueue {
    if (_executings.count < MaxConcurrentCount && _waitingURLs.count > 0) {
        BOOL findAvailUrl = NO;
        if (GET_SERVICE(CSNetworkReachabilityManager).reachableViaWiFi) { //wifi
            NSURL* url = [[_waitingURLs firstObject] copy];
            CSDownloadModel* model = [_waitings objectForKey:url];
            if (model) {
                if (!model.operation.isCancel) {
                    _executings[url] = model;
                    [model.operation start];
                }
                [_waitingURLs removeObject:url];
                [_waitings removeObjectForKey:url];
            }
            findAvailUrl = YES;
        } else if (GET_SERVICE(CSNetworkReachabilityManager).reachableViaWWAN) { //这里要判断下载了
            NSURL* url;
            CSDownloadModel* model;
            
            NSMutableArray* needFailURLs = [NSMutableArray arrayWithCapacity:_waitings.count];
            
            for (url in _waitingURLs) {
                model = [_waitings objectForKey:url];
                if (model) {
                    if (model.requestOnAnyNetWork) {
                        findAvailUrl = YES;
                        break;
                    } else {
                        NSError* resultError = [NSError errorWithDomain:@"CSDownloader" code:3 userInfo:@{@"msg":@"网络不支持", @"当前网络":@"Cellular", @"需要网络":@"WiFi"}];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            for (CSDownloaderCompletedBlock completeBlock in model.completeBlocks) {
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
            CSDownloadModel* model;
            for (url in _waitingURLs) {
                model = [_waitings objectForKey:url];
                if (model) {
                    NSError* resultError = [NSError errorWithDomain:@"CSDownloader" code:3 userInfo:@{@"msg":@"网络不支持", @"当前网络":@"无网络", @"需要网络":model.requestOnAnyNetWork? @"AnyNetwork": @"WiFi"}];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        for (CSDownloaderCompletedBlock completeBlock in model.completeBlocks) {
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

- (void)changeStatusFrom:(CSNetworkReachabilityStatus)last to:(CSNetworkReachabilityStatus)current {
    if (current == last) {
        return;
    }
    if (current != CSNetworkReachabilityStatusReachableViaWiFi && current != CSNetworkReachabilityStatusReachableViaWWAN) { //无网络，全暂停
        [self setSuspended:YES];
        return;
    }
    if (current == CSNetworkReachabilityStatusReachableViaWiFi) { //当前是wifi，启动新请求
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
    CSDownloadModel* model = _executings[downloadTask.originalRequest.URL];
    if (model && model.localPath) {
        NSString* hashCode = model.sha256HashCode;
        
        if (!CSEmptyString(hashCode) && ![hashCode isEqualToString:[CSDownloader SHA256HashCodeWithURL:model.URL]]) {
            model.hashCodeVerifyFail = YES;
            return;
        }
        
        NSURL *toURL = [NSURL fileURLWithPath:model.localPath];
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager moveItemAtURL:location toURL:toURL error:nil];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    __block CSDownloadModel *model;
    dispatch_barrier_sync(self.barrierQueue, ^{
        model = [_executings[task.originalRequest.URL] copy];
        if (task.state == NSURLSessionTaskStateCanceling || task.state == NSURLSessionTaskStateCompleted) {
            [_executings removeObjectForKey:task.originalRequest.URL];
        }
        [self flushWaitingQueue];
    });
    if (model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* localPath = model.localPath;
            if (error == nil && task.state == NSURLSessionTaskStateCompleted) { //下载成功
                if (!CSEmptyString(model.sha256HashCode) && model.hashCodeVerifyFail) { //验证失败
                    NSError* resultError = [NSError errorWithDomain:@"CSDownloader" code:4 userInfo:@{@"msg":@"hashcode验证失败", @"url":model.URL, @"hashcode":model.sha256HashCode}];
                    for (CSDownloaderCompletedBlock completeBlock in model.completeBlocks) {
                        completeBlock(localPath, resultError, NO);
                    }
                    return;
                }
            }
            
            for (CSDownloaderCompletedBlock completeBlock in model.completeBlocks) {
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
    
    __block CSDownloadModel *model;
    dispatch_sync(self.barrierQueue, ^{
        model = [_executings[downloadTask.originalRequest.URL] copy];
    });
    if (model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (CSDownloaderProgressBlock progressBlock in model.progressBlocks) {
                progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
            }
        });
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    __block CSDownloadModel *model;
    dispatch_sync(self.barrierQueue, ^{
        model = [_executings[downloadTask.originalRequest.URL] copy];
    });
    if (model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (CSDownloaderProgressBlock progressBlock in model.progressBlocks) {
                progressBlock(fileOffset, expectedTotalBytes);
            }
        });
    }
}

//所有的下载完成都走这里
+ (NSString*)SHA256HashCodeWithURL:(NSURL*)URL {
    NSData* dataIn = [NSData dataWithContentsOfURL:URL];
    return [CSDownloader SHA256HashCode:dataIn];
}

//所有的本地读取都走这里
+ (NSString*)SHA256HashCodeWithFilePath:(NSString*)filePath {
    NSData* dataIn = [NSData dataWithContentsOfFile:filePath];
    return [CSDownloader SHA256HashCode:dataIn];
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
