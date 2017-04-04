//
//  UIBarButtonItem+QTheme.h
//  BusTrack
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (QTheme)

+ (UIBarButtonItem *)barbuttonItemWithTheme:(NSString *)theme target:(id)target action:(SEL)selector;
+ (UIBarButtonItem *)barbuttonItemWithTheme:(NSString *)theme target:(id)target action:(SEL)selector alignmentLeft:(BOOL)left;
+ (UIBarButtonItem *)barbuttonItemWithTheme:(NSString *)theme title:(NSString *)title target:(id)target action:(SEL)selector alignmentLeft:(BOOL)left;
+ (UIBarButtonItem *)modalBarbuttonItemWithTheme:(NSString *)theme title:(NSString *)title target:(id)target action:(SEL)selector alignmentLeft:(BOOL)left;

@end
