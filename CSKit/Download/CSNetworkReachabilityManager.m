//
//  CSNetworkReachabilityManager.m
//  CSKit
//
//  Created by song on 16/8/4.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "CSNetworkReachabilityManager.h"
#import <AFNetWorking/AFNetworkReachabilityManager.h>
#import "CSBus.h"

@implementation CSNetworkReachabilityManager {
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
    CSNetworkReachabilityStatus last = _networkReachabilityStatus;
    _networkReachabilityStatus = [[notification.userInfo objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue];
    POST_EVENT(CSNetWorkChangeExt, changeStatusFrom:last to:_networkReachabilityStatus);
}

- (BOOL)isReachable {
    return _networkReachabilityStatus != CSNetworkReachabilityStatusNotReachable;
}

- (BOOL)isReachableViaWiFi {
    return _networkReachabilityStatus == CSNetworkReachabilityStatusReachableViaWiFi;
}

- (BOOL)isReachableViaWWAN {
    return _networkReachabilityStatus == CSNetworkReachabilityStatusReachableViaWWAN;
}
@end
