//
//  QDDownloadModel.m
//  QDKit
//
//  Created by song on 16/5/30.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDDownloadModel.h"
@implementation QDDownloadModel

- (id)copyWithZone:(NSZone *)zone{
    QDDownloadModel *model = [[[self class] allocWithZone:zone] init];
    model.URL = self.URL;
    model.resumeData = self.resumeData;
    model.completeBlocks = self.completeBlocks;
    model.progressBlocks  = self.progressBlocks;
    model.operation = self.operation;
    model.localPath = self.localPath;
    model.requestOnAnyNetWork = self.requestOnAnyNetWork;
    model.sha256HashCode = self.sha256HashCode;
    model.hashCodeVerifyFail = self.hashCodeVerifyFail;
    return model;
}

- (NSMutableArray<QDDownloaderCompletedBlock>*) completeBlocks {
    if (_completeBlocks == nil) {
        _completeBlocks = [NSMutableArray array];
    }
    return _completeBlocks;
}

- (NSMutableArray<QDDownloaderProgressBlock>*) progressBlocks {
    if (_progressBlocks == nil) {
        _progressBlocks = [NSMutableArray array];
    }
    return _progressBlocks;
}

@end
