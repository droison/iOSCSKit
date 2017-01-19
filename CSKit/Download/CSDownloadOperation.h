//
//  CSDownloadOperation.h
//  QDaily
//
//  Created by 淞 柴 on 16/5/30.
//  Copyright © 2016年 Qdaily. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSDownloadModel;

@interface CSDownloadOperation : NSObject

- (instancetype)initWithModel:(CSDownloadModel *)model session:(NSURLSession *)session;

@property (nonatomic, weak) CSDownloadModel *model;
@property (nonatomic, strong, readonly) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, assign, readonly) BOOL isCancel;

- (void)start;
- (void)suspend;
- (void)resume;
- (void)cancel;

@end
