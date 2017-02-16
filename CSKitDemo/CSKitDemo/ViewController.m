//
//  ViewController.m
//  CSKit
//
//  Created by song on 2017/1/13.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "ViewController.h"
#import "CSDownloadManager.h"
#import "CSNetworkReachabilityManager.h"
#import "CSBus.h"

@interface ViewController ()<CSNetWorkChangeExt>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    REGISTER_OBSERVER(CSNetWorkChangeExt, self);
}

- (void)changeStatusFrom:(CSNetworkReachabilityStatus)from to:(CSNetworkReachabilityStatus)to {
    NSArray* urlArray = @[@"http://app3.qdaily.com/assets/qdaily/injection/jsbridge-e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855.js",
                          @"http://app3.qdaily.com/assets/app3/common-e97a9a5c289575d150cfd2c140388afc867a61855af66c5fda6543f87509b964.js",
                          @"http://app3.qdaily.com/assets/app3/articles/show-1484e7b1b37857f6c9d02c5a2e6a9a20c935263f1d22a5234113a93bfa64188c.js",
                          @"http://app3.qdaily.com/assets/app3/common-e4d9a99900682f2cf4945f48f07eafdd7d95854544c16f7d383ba591841a6b1b.css",
                          @"http://app3.qdaily.com/assets/app3/articles/show-7dd6539a4ae87d21747242f1eb11dab4241ac290175b70eeadaf9272d2141604.css",
                          @"http://img.qdaily.com/article/article_show/20160702103028nbPDJXT7oVQz6ruC.jpg?imageMogr2/auto-orient/thumbnail/!906x540r/gravity/Center/crop/906x540/quality/85/format/jpg/ignore-error/1",
                          @"http://img.qdaily.com/uploads/20160702103016chVXdaWFspkDeYOi.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103017tR4FeD1mLVI2Jqpl.jpg-w600",
                          @"http://img.qdaily.com/uploads/2016070210301702Ob9AtrX7FBajVu.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103018DFhxH34bY9cXr6jv.jpg-w600",
                          @"http://img.qdaily.com/uploads/201607021030186Dy58vdcXiEwjnIu.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103019EcwPhM1vDSqQoGZi.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103019txDoreph9kgwqMKX.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103020WsLQ4kdJhx3qKwj9.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103020HN1iwKVet4zSZmqx.jpg-w600",
                          @"http://img.qdaily.com/uploads/2016070210302192pWc1C5QvHxiGLb.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103021n1jZu4XPabikdh0J.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103022oAFLYaMDkuwH5B9O.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103022km4zM6wRbLDFvc8r.jpg-w600",
                          @"http://img.qdaily.com/uploads/2016070210302335Id2cROBvjpxSJN.jpg-w600",
                          @"http://img.qdaily.com/uploads/201607021030233A1NtyDsS2CPxbGR.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103024PJavuIC3FzO5o4eq.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103024rIxhsdYMJ3uZoOaE.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103025yLNX8SvqsH2OpZk7.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103025BMFQbegUwmqTri4Z.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103026u0tXJ24L1rnKxGjd.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103026x1pd05hbzYuCHSaj.jpg-w600",
                          @"http://img.qdaily.com/uploads/201607021030276LWqBxUz59DQGaME.jpg-w600",
                          @"http://img.qdaily.com/uploads/20160702103027NqadysRHJeivS1VK.jpg-w600",
                          @"http://img.qdaily.com/article/article_show/20160606154933l3S12OvwfUGozAxr.jpg?imageMogr2/auto-orient/thumbnail/!640x380r/gravity/Center/crop/640x380/quality/85/format/jpg/ignore-error/1"];
    
    for (NSString* strUrl in urlArray) {
        [GET_SERVICE(CSDownloadManager) downloadWithURL:[NSURL URLWithString:strUrl] options:(CSDownloadMgrAnyNetwork) progress:nil complete:^(NSString *localPath, NSError *error, BOOL finished) {
            if (finished && localPath) {
                CSLog(@"文件下载成功，地址为：%@", localPath);
            } else {
                CSLog(@"文件下载失败，原因为：%@", error);
            }
        }];
    }
}

@end
