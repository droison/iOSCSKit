//
//  CSRouter.h
//  droison
//
//  Created by song on 17/1/5.
//  Copyright © 2017年 droison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CServiceCenter.h"
#import "CSMacro.h"

@protocol QDeepLinkProtocol <NSObject>
- (instancetype)initWithURLParams:(NSDictionary*)params;
@end

typedef BOOL(^CSRouterFail)(NSURL *url, UIViewController* viewController, BOOL isPresent);

@interface CSRouter : CService<CService>

- (CSRouter*) addScheme:(NSString*) scheme, ...;
- (CSRouter*) addHost:(NSString*) scheme, ...;
- (CSRouter*) setDefaultNavigation:(UINavigationController*) naviController;
- (CSRouter*) setRouteFailBlock:(CSRouterFail) fail;

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
CS_EXTERN void RouterRegister(Class, NSString*, ...); \
+ (void)load { RouterRegister(self, ##__VA_ARGS__, nil); }
