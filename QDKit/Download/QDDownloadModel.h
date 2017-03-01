//
//  QDDownloadModel.h
//  QDKit
//
//  Created by song on 16/5/30.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QDDownloadOperation;

typedef void(^QDDownloaderProgressBlock)(int64_t receivedSize, int64_t expectedSize);

typedef void(^QDDownloaderCompletedBlock)(NSString *localPath, NSError *error, BOOL finished);

@interface QDDownloadModel : NSObject <NSCopying>

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSData *resumeData;
@property (nonatomic, strong) QDDownloadOperation *operation;

@property (nonatomic, assign) BOOL requestOnAnyNetWork;

@property (nonatomic, strong) NSString* sha256HashCode;
@property (nonatomic, assign) BOOL hashCodeVerifyFail;
// 下载后存储到此处
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, strong) NSMutableArray<QDDownloaderCompletedBlock>* completeBlocks;
@property (nonatomic, strong) NSMutableArray<QDDownloaderProgressBlock>* progressBlocks;

@end
