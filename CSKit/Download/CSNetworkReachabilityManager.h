//
//  CSNetworkReachabilityManager.h.h
//  CSKit
//
//  Created by song on 16/8/4.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "CServiceCenter.h"

typedef NS_ENUM(NSInteger, CSNetworkReachabilityStatus) {
    CSNetworkReachabilityStatusUnknown          = -1,
    CSNetworkReachabilityStatusNotReachable     = 0,
    CSNetworkReachabilityStatusReachableViaWWAN = 1,
    CSNetworkReachabilityStatusReachableViaWiFi = 2,
};

@protocol CSNetWorkChangeExt <NSObject>
- (void) changeStatusFrom:(CSNetworkReachabilityStatus)from to:(CSNetworkReachabilityStatus)to;
@end

@interface CSNetworkReachabilityManager : CService<CService>
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;

/**
 Whether or not the network is currently reachable via WWAN.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;

/**
 Whether or not the network is currently reachable via WiFi.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

@property (readonly, nonatomic, assign) CSNetworkReachabilityStatus networkReachabilityStatus;

@end
