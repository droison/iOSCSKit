//
//  QDDownloadOperation.m
//  QDKit
//
//  Created by song on 16/5/30.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDDownloadOperation.h"
#import "QDDownloadModel.h"
#import "QDKitMacro.h"
#import <objc/runtime.h>

#define kKVOBlock(KEYPATH, BLOCK) \
[self willChangeValueForKey:KEYPATH]; \
BLOCK(); \
[self didChangeValueForKey:KEYPATH];

static NSTimeInterval kTimeoutInterval = 8.0;

@interface QDDownloadOperation () {
    BOOL _cancel;
}

@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, weak) NSURLSession *session;

@end

@implementation QDDownloadOperation

- (instancetype)initWithModel:(QDDownloadModel *)model session:(NSURLSession *)session {
    if (self = [super init]) {
        self.model = model;
        self.session = session;
    }
    return self;
}

- (void)dealloc {
    self.task = nil;
}



- (void)statRequest {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.model.URL
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTimeoutInterval];
    self.task = [self.session downloadTaskWithRequest:request];
}

- (void)start {
    [self resume];
}

- (BOOL)isCancel {
    return _cancel;
}

- (void)suspend {
    if (self.task) {
        WeakSelf;
        [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            StrongSelf;
            self.model.resumeData = resumeData;
        }];
        [self.task suspend];
    }
}

- (void)resume {
    if (_cancel) {
        return;
    }
    if (_task.state == NSURLSessionTaskStateCompleted) {
        return;
    }
    
    if (self.model.resumeData) {
        self.task = [self.session downloadTaskWithResumeData:self.model.resumeData];
    } else if (self.task == nil) {
        [self statRequest];
    }
    [self.task resume];
}

- (NSURLSessionDownloadTask *)downloadTask {
    return self.task;
}

- (void)cancel {
    _cancel = YES;
    [self.task cancel];
    self.task = nil;
}
@end
