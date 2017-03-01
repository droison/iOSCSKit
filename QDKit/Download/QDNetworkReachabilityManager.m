//
//  QDNetworkReachabilityManager.m
//  QDKit
//
//  Created by song on 16/8/4.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDNetworkReachabilityManager.h"
#import <AFNetWorking/AFNetworkReachabilityManager.h>
#import "QDBus.h"

@implementation QDNetworkReachabilityManager {
    AFNetworkReachabilityManager *_reachabilityManager;

}

- (void)onServiceInit {
    _reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [_reachabilityManager startMonitoring];
    _networkReachabilityStatus = (int)_reachabilityManager.networkReachabilityStatus;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkReachabilityStatusChanged:)
                                                name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)onServiceTerminate {
    [_reachabilityManager stopMonitoring];
}

- (void)networkReachabilityStatusChanged:(NSNotification *)notification {
    QDNetworkReachabilityStatus last = _networkReachabilityStatus;
    _networkReachabilityStatus = [[notification.userInfo objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue];
    POST_EVENT(CSNetWorkChangeExt, changeStatusFrom:last to:_networkReachabilityStatus);
}

- (BOOL)isReachable {
    return _networkReachabilityStatus != QDNetworkReachabilityStatusNotReachable;
}

- (BOOL)isReachableViaWiFi {
    return _networkReachabilityStatus == QDNetworkReachabilityStatusReachableViaWiFi;
}

- (BOOL)isReachableViaWWAN {
    return _networkReachabilityStatus == QDNetworkReachabilityStatusReachableViaWWAN;
}
@end
