//
//  QDDeviceInfo.m
//  BusTrack
//
//  Created by song on 14-10-16.
//  Copyright (c) 2014年 droison. All rights reserved.
//

#import "QDDeviceInfo.h"

@implementation QDDeviceInfo

+ (int)screenScale {
    static BOOL s_screenScale = 2;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            s_screenScale = [[UIScreen mainScreen] scale];
        }
    });
    
    return s_screenScale;
}

+ (int)screenWidth {
    static BOOL s_screenWidth = 375;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_screenWidth = MIN( [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height);
    });
    
    return s_screenWidth;
}

+ (int)screenHeight {
    static BOOL s_screenHeight = 667;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_screenHeight = MAX( [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height);
    });
    
    return s_screenHeight;
}

+ (BOOL) isiPhone
{
    NSString *nsModel = [UIDevice currentDevice].model;
    return [nsModel hasPrefix:@"iPhone"];
}

double g_iOSVersion = 0;
double getiOSVersion()
{
    if (g_iOSVersion < 0.1) {
        NSString *nsOsversion = [UIDevice currentDevice].systemVersion;
        g_iOSVersion = atof([nsOsversion UTF8String]);
    }
    return g_iOSVersion;
}

+ (BOOL) isiOS9plus
{
    if (getiOSVersion() > 8.9) {
        return YES;
    }
    
    return NO;
}

+ (BOOL) isiOS10plus
{
    if (getiOSVersion() > 9.9) {
        return YES;
    }
    
    return NO;
}

+ (BOOL) isiOS8plus
{
    if (getiOSVersion() > 7.9) {
        return YES;
    }
    
    return NO;
}

+ (BOOL) isiOS7_1plus
{
    if (getiOSVersion() > 7.09) {
        return YES;
    }
    
    return NO;
}

+ (BOOL) isiOS7plus
{
    if (getiOSVersion() > 6.9) {
        return YES;
    }
    
    return NO;
}

+ (BOOL) isiOS7
{
    if  (getiOSVersion() > 6.9 && getiOSVersion() < 7.9) {
        return YES;
    }
    
    return NO;
}

static BOOL g_is320wScreen = NO;
static BOOL g_hasDetectIs320wScreen = NO;
static BOOL g_is480hScreen = NO;
static BOOL g_hasDetectIs480hScreen = NO;
static BOOL g_is568hScreen = NO;
static BOOL g_hasDetectIs568hScreen = NO;
static BOOL g_is667hScreen = NO;
static BOOL g_hasDetectIs667hScreen = NO;
static BOOL g_is736hScreen = NO;
static BOOL g_hasDetectIs736hScreen = NO;

+ (BOOL) is480hScreen {
    if (g_hasDetectIs480hScreen == NO) {
        g_hasDetectIs480hScreen = YES;
        
        int height = [self screenHeight];
        g_is480hScreen = (height == 480);
    }
    return g_is480hScreen;
}

+ (BOOL) is568hScreen
{
    if (g_hasDetectIs568hScreen == NO) {
        g_hasDetectIs568hScreen = YES;
        
        int height = [self screenHeight];
        g_is568hScreen = (height == 568);
    }
    return g_is568hScreen;
}

+ (BOOL) is667hScreen
{
    if (g_hasDetectIs667hScreen == NO) {
        g_hasDetectIs667hScreen = YES;
        
        int height = [self screenHeight];
        g_is667hScreen = (height == 667);
    }
    return g_is667hScreen;
}

+ (BOOL) is736hScreen
{
    if (g_hasDetectIs736hScreen == NO) {
        g_hasDetectIs736hScreen = YES;
        
        int height = [self screenHeight];
        g_is736hScreen = (height == 736);
    }
    return g_is736hScreen;
}

+ (BOOL) is320wScreen{
    if (g_hasDetectIs320wScreen == NO) {
        g_hasDetectIs320wScreen = YES;
        
        int width = [self screenWidth];
        g_is320wScreen = (width == 320);
    }
    return g_is320wScreen;
}

+ (BOOL) isiPhone6pScreen{
    return [self is736hScreen];
}

+ (BOOL) isiPhone6Screen{
    return [self is667hScreen];
}

#pragma mark - tools

+ (BOOL)is2xScreen {
    return [self screenScale] == 2;
}

+ (BOOL)is3xScreen {
    return [self screenScale] == 3;
}

+ (BOOL)is568H2xScreen {
    // will not change in one app life circle.
    // so we cache it for better performance.
    static int is568H2XScreen = -1;
    if (is568H2XScreen == -1) {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && [[UIScreen mainScreen] scale] == 2
            && [self screenHeight] == 568.0f
            && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
            ) {
            is568H2XScreen = 1;
        } else {
            is568H2XScreen = 0;
        }
    }
    return is568H2XScreen == 1;
}

#pragma mark - ipad判断

+ (BOOL) isiPad
{
    static BOOL s_isiPad = NO;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *nsModel = [UIDevice currentDevice].model;
        s_isiPad = [nsModel hasPrefix:@"iPad"];
    });
    
    return s_isiPad;
}
@end
