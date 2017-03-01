//
//  QDRouter.h
//  CSKit
//
//  Created by song on 17/1/5.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QDServiceCenter.h"
#import "CSKitMacro.h"

@protocol QDeepLinkProtocol <NSObject>
- (instancetype)initWithURLParams:(NSDictionary*)params;
@end

typedef BOOL(^QDRouterFail)(NSURL *url, UIViewController* viewController, BOOL isPresent);

@interface QDRouter : QDService<QDService>

- (QDRouter*) addScheme:(NSString*) scheme, ...;
- (QDRouter*) addHost:(NSString*) scheme, ...;
- (QDRouter*) setDefaultNavigation:(UINavigationController*) naviController;
- (QDRouter*) setRouteFailBlock:(QDRouterFail) fail;

- (BOOL) pushURLStr:(NSString*)url navigationController:(UINavigationController*) viewController;
- (BOOL) presentURLStr:(NSString*)url viewcontroller:(UIViewController*) viewController;

- (BOOL) pushURL:(NSURL*)url navigationController:(UINavigationController*) viewController;
- (BOOL) presentURL:(NSURL*)url viewcontroller:(UIViewController*) viewController;


//以下两个无视scheme host
- (BOOL) push:(NSString*)routerName params:(NSDictionary*)params navigationController:(UINavigationController*) viewController;
- (BOOL) present:(NSString*)routerName params:(NSDictionary*)params viewcontroller:(UIViewController*) viewController;

- (UIViewController*) matchViewControllerURLStr:(NSString*)url;
- (UIViewController*) matchViewControllerURL:(NSURL*)url;
- (UIViewController*) matchViewController:(NSString*)routerName params:(NSDictionary*)params;
@end

#define ROUTER_REGISTER(...) \
QD_EXTERN void RouterRegister(Class, NSString*, ...); \
+ (void)load { RouterRegister(self, ##__VA_ARGS__, nil); }
