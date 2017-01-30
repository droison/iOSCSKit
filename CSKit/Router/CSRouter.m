//
//  CSRouter.m
//  CSKit
//
//  Created by song on 17/1/5.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "CSRouter.h"
#import <objc/runtime.h>
#import "NSURL+CSParams.h"

@interface Router : NSObject
@property(nonatomic, strong) Class viewControllerClass;
@property(nonatomic, strong) NSArray* params;
@end

@implementation Router
@end

static NSMutableDictionary<NSString*, Router*> *RouterMap;
NSMutableDictionary<NSString*, Router*> *GetRouterMap(void)
{
    return RouterMap;
}

void RouterRegister(Class class, NSString* params, ...);
void RouterRegister(Class class, NSString* params, ...)
{
    if (class == nil || !class_conformsToProtocol(class, @protocol(QDeepLinkProtocol))) {
        return;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RouterMap = [NSMutableDictionary new];
    });
    
    NSString* routerName = params;
    NSMutableArray *paramArray = [NSMutableArray array];
    va_list args;
    va_start(args, params);
    {
        NSString* arg;
        while ((arg = va_arg(args, NSString *))) {
            [paramArray addObject:arg];
        }
    }
    va_end(args);
    
    Router* router = [[Router alloc] init];
    router.params = paramArray;
    router.viewControllerClass = class;
    
    [RouterMap setObject:router forKey:routerName];
}

@implementation CSRouter {
    NSMutableSet* _schemes;
    NSMutableSet* _hosts;
    __weak UINavigationController* _defaultNavigator;
    CSRouterFail _routeFailBlock;
}

-(void)onServiceInit {
    _schemes = [NSMutableSet new];
    _hosts = [NSMutableSet new];
}

-(CSRouter *)addScheme:(NSString *)scheme, ... {
    if (scheme) {
        [_schemes addObject:scheme];
        va_list args;
        va_start(args, scheme);
        NSString *eachScheme;
        while ((eachScheme = va_arg(args, NSString *))) {
            [_schemes addObject:eachScheme];
        }
        va_end(args);
    }
    return self;
}

-(CSRouter *)addHost:(NSString *)host, ... {
    if (host) {
        [_hosts addObject:host];
        va_list args;
        va_start(args, host);
        NSString *eachHost;
        while ((eachHost = va_arg(args, NSString *))) {
            [_hosts addObject:eachHost];
        }
        va_end(args);
    }
    return self;
}


-(CSRouter *)setDefaultNavigation:(UINavigationController *)naviController {
    _defaultNavigator = naviController;
    return self;
}

-(CSRouter *)setRouteFailBlock:(CSRouterFail)fail {
    _routeFailBlock = fail;
    return self;
}

- (BOOL) pushURLStr:(NSString*)url navigationController:(UINavigationController*) viewController {
    return [self pushURL:[NSURL URLWithString:url] navigationController:viewController];
}

- (BOOL) presentURLStr:(NSString*)url viewcontroller:(UIViewController*) viewController {
    return [self presentURL:[NSURL URLWithString:url] viewcontroller:viewController];
}

- (BOOL) pushURL:(NSURL*)url navigationController:(UINavigationController*) viewController {
    if (!viewController) {
        viewController = _defaultNavigator;
    }
    if (url) {
        NSString* scheme = url.scheme;
        NSString* host = url.host;
        NSString* routeName = url.firstPath;
        
        BOOL result;
        if ([self->_schemes containsObject:scheme] && [self->_hosts containsObject:host]) {
            result = [self push:routeName params:[url parameters] navigationController:viewController];
        }
        if (!result && _routeFailBlock) {
            _routeFailBlock(url, viewController, NO);
        }
        return result;
    }
    return NO;
}

- (BOOL) presentURL:(NSURL*)url viewcontroller:(UIViewController*) viewController {
    if (!viewController) {
        viewController = _defaultNavigator;
    }
    if (url) {
        NSString* scheme = url.scheme;
        NSString* host = url.host;
        NSString* routeName = url.firstPath;
        
        BOOL result;
        if ([self->_schemes containsObject:scheme] && [self->_hosts containsObject:host]) {
            result = [self present:routeName params:[url parameters] viewcontroller:viewController];
        }
        if (!result && _routeFailBlock) {
            _routeFailBlock(url, viewController, YES);
        }
    }
    return NO;
}

- (BOOL) push:(NSString*)routerName params:(NSDictionary*)params navigationController:(UINavigationController*) viewController {
    if (!viewController) {
        viewController = _defaultNavigator;
    }
    UIViewController* newVC = [self matchViewController:routerName params:params];
    if (newVC) {
        [viewController pushViewController:newVC animated:YES];
        return YES;
    }
    
    return NO;
}

- (BOOL) present:(NSString*)routerName params:(NSDictionary*)params viewcontroller:(UIViewController*) viewController {
    if (!viewController) {
        viewController = _defaultNavigator;
    }
    UIViewController* newVC = [self matchViewController:routerName params:params];
    if (newVC) {
        [viewController presentViewController:newVC animated:YES completion:nil];
        return YES;
    }
    return NO;
}


- (UIViewController*) matchViewControllerURLStr:(NSString*)url {
    return [self matchViewControllerURL:[NSURL URLWithString:url]];
}

- (UIViewController*) matchViewControllerURL:(NSURL*)url {
    if (url) {
        NSString* scheme = url.scheme;
        NSString* host = url.host;
        NSString* routeName = url.firstPath;
        if ([self->_schemes containsObject:scheme] && [self->_hosts containsObject:host]) {
            return [self matchViewController:routeName params:[url parameters]];
        }
    }
    return nil;
}

- (UIViewController*) matchViewController:(NSString*)routerName params:(NSDictionary*)params {
    if (routerName) {
        Router* router = GetRouterMap()[routerName];
        if (router != nil) {
            for (NSString* key in router.params) {
                if (params[key] == nil) {
                    return nil;
                }
            }
            return [[router.viewControllerClass alloc] initWithURLParams:params];
        }
    }
    return nil;
}

@end
