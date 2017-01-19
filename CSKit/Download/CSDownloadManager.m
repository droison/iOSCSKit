//
//  CSDownloadManager.m
//  QDaily
//
//  Created by 淞 柴 on 16/5/30.
//  Copyright © 2016年 Qdaily. All rights reserved.
//

#import "CSDownloadManager.h"
#import "CSDownloadOperation.h"
#import "CSKitMacro.h"
#import <CommonCrypto/CommonDigest.h>

#ifndef LibraryFolder
#define LibraryFolder  ([NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0])
#endif

static NSString *const CSURLDownloadCacheFolderName = @"downloadCache";
static NSString *const CSURLDownloadFolderName = @"download";

@interface CSDownloadManager ()

@property(nonatomic, strong)NSFileManager *fileManager;
@property(nonatomic, strong)dispatch_queue_t ioQueue;
@property(nonatomic, strong)CSDownloader *downloader;
@end

@implementation CSDownloadManager

#pragma mark - life cycle
- (void)onServiceInit {
    //initialize code here
    self.ioQueue = dispatch_queue_create("com.qdaily.downloader.queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(_ioQueue, ^{
        _fileManager = [NSFileManager defaultManager];
    });
    _downloader = GET_SERVICE(CSDownloader);
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
#warning todo 缓存的更优处理
    
    //首先根据url去本地读取,本地没有进入下一步
    NSString *filePath = nil;
    if (!CSEmptyString(destinationPath)) {
        filePath = destinationPath;
    } else
    {
        filePath =  [self filePathWithURL:url persist:(options & CSDownloadMgrCachePersist)];
    }
    
    if (!(options & CSDownloadMgrRefreshCached) && filePath && [self.fileManager fileExistsAtPath:filePath]) {
        BOOL complete = YES;
        if (!CSEmptyString(hashCode)) {
            if (![hashCode isEqualToString:[CSDownloader SHA256HashCodeWithFilePath:filePath]]) {
                complete = NO;
                [self.fileManager removeItemAtPath:filePath error:nil]; //hashcode验证不通过，直接删掉
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
    
    CSDownloadOperation* operation;
    //网络状况,由downloader自己去处理
    if (options & CSDownloadMgrAnyNetwork) {
        operation = [_downloader downloadWithURL:url destinationPath:filePath options:CSDownloaderAnyNetwork progress:progress complete:completeBlock];
    } else {
        operation = [_downloader downloadWithURL:url destinationPath:filePath options:0 progress:progress complete:completeBlock];
    }
    
    if (!CSEmptyString(hashCode)) {
        operation.model.sha256HashCode = hashCode;
    }
}

#pragma mark - Library Folder Path

- (NSString *)libraryPathWithFolderName:(NSString *)folderName {
    
    NSString *libraryFolder = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingPathComponent:folderName];
    NSString *folderPath = [LibraryFolder stringByAppendingPathComponent:libraryFolder];
    
    if (![self.fileManager fileExistsAtPath:folderPath]) {
        [self.fileManager createDirectoryAtPath:folderPath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:nil];
    }
    
    return folderPath;
}

- (NSString *)filePathWithURL:(NSURL *)url persist:(BOOL)persist{
    NSString *filename = [NSString stringWithFormat:@"%@.%@", [self md5Hash:url.absoluteString], url.absoluteString.pathExtension];
    return [[self libraryPathWithFolderName:persist? CSURLDownloadFolderName : CSURLDownloadCacheFolderName] stringByAppendingPathComponent:filename];
}

//根据url查找判断本地有没有该文件
- (BOOL)localExistsForURL:(NSURL *)URL {
    return [self.fileManager fileExistsAtPath:[self filePathWithURL:URL persist:NO]] || [self.fileManager fileExistsAtPath:[self filePathWithURL:URL persist:YES]];
}

- (void)localFileForURL:(NSURL *)URL complete:(void(^) (BOOL exsit, NSURL* localPathURL)) completeBlock {
    BOOL exist = NO;
    NSString *localCachedPath = nil;
    if (URL) {
        localCachedPath = [self filePathWithURL:URL persist:NO];
        exist = [self.fileManager fileExistsAtPath:localCachedPath];
        if (!exist) {
            localCachedPath = [self filePathWithURL:URL persist:YES];
            exist = [self.fileManager fileExistsAtPath:localCachedPath];
        }
    }
    
    if (completeBlock) {
        if (exist) {
            completeBlock(YES, [NSURL fileURLWithPath:localCachedPath]);
        } else {
            completeBlock(NO, nil);
        }
        
    }
}

#pragma mark - file clear

- (void)removeFileWithURL:(NSURL *)url {
    if ([self localExistsForURL:url]) {
        dispatch_async(self.ioQueue, ^{
            [self.fileManager removeItemAtURL:[NSURL fileURLWithPath:[self filePathWithURL:url persist:NO]] error:nil];
            [self.fileManager removeItemAtURL:[NSURL fileURLWithPath:[self filePathWithURL:url persist:YES]] error:nil];
        });
    }
}

//直接把文件夹干掉
- (void)clearAllFile {
    [self clearAllFileWithCompletion:nil];
}

- (void)clearAllFileWithCompletion:(void(^)())completeBlock
{
    dispatch_async(self.ioQueue, ^{
        [_fileManager removeItemAtPath:[self libraryPathWithFolderName:CSURLDownloadFolderName] error:nil];
        [_fileManager createDirectoryAtPath:[self libraryPathWithFolderName:CSURLDownloadFolderName]
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:NULL];
        
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock();
            });
        }
    });
}

- (NSString *)md5Hash:(NSString*)str {
    if (CSEmptyString(str)) {
        return @"";
    }
    
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (int)[data length], result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}
@end
