//
//  QDNetworkReachabilityManager.h.h
//  QDKit
//
//  Created by song on 16/8/4.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDServiceCenter.h"

typedef NS_ENUM(NSInteger, QDNetworkReachabilityStatus) {
    QDNetworkReachabilityStatusUnknown          = -1,
    QDNetworkReachabilityStatusNotReachable     = 0,
    QDNetworkReachabilityStatusReachableViaWWAN = 1,
    QDNetworkReachabilityStatusReachableViaWiFi = 2,
};

@protocol CSNetWorkChangeExt <NSObject>
- (void) changeStatusFrom:(QDNetworkReachabilityStatus)from to:(QDNetworkReachabilityStatus)to;
@end

@interface QDNetworkReachabilityManager : QDService<QDService>
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;

/**
 Whether or not the network is currently reachable via WWAN.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;

/**
 Whether or not the network is currently reachable via WiFi.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

@property (readonly, nonatomic, assign) QDNetworkReachabilityStatus networkReachabilityStatus;

@end
