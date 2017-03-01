//
//  QDDownloadOperation.h
//  CSKit
//
//  Created by song on 16/5/30.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QDDownloadModel;

@interface QDDownloadOperation : NSObject

- (instancetype)initWithModel:(QDDownloadModel *)model session:(NSURLSession *)session;

@property (nonatomic, weak) QDDownloadModel *model;
@property (nonatomic, strong, readonly) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, assign, readonly) BOOL isCancel;

- (void)start;
- (void)suspend;
- (void)resume;
- (void)cancel;

@end
