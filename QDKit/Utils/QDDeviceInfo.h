//
//  QDDeviceInfo.h
//  QDKit
//
//  Created by song on 14-10-16.
//  Copyright (c) 2014年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QDDeviceInfo : NSObject

+ (int) screenScale;
+ (int) screenWidth;
+ (int) screenHeight;

+ (BOOL) isiPhone;

+ (BOOL) isiOS10plus;
+ (BOOL) isiOS9plus;
+ (BOOL) isiOS8plus;
+ (BOOL) isiOS7_1plus;
+ (BOOL) isiOS7plus;
+ (BOOL) isiOS7;

+ (BOOL) is480hScreen;
+ (BOOL) is568hScreen;
+ (BOOL) is667hScreen;
+ (BOOL) is736hScreen;

+ (BOOL) is320wScreen;
//根据屏幕分辨率判断的是否是6p的标准模式
+ (BOOL) isiPhone6pScreen;
//根据屏幕分辨率判断的是否是6的标准模式
+ (BOOL) isiPhone6Screen;

+ (BOOL)is2xScreen;

+ (BOOL)is3xScreen;


+ (BOOL)is568H2xScreen;

+ (BOOL) isiPad;          //表示它是一个iPad，可能有很多种类

@end
