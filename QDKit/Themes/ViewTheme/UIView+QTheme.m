//
//  UIView+QTheme.m
//  BusTrack
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "UIView+QTheme.h"
#import "QDThemeUtil.h"
#import <objc/runtime.h>
#import "QDDeviceInfo.h"

@interface UIView ()

@property (nonatomic, copy) NSString *themePath;

@end

@implementation UIView (QTheme)

- (void)setThemePath:(NSString *)theme {
    objc_setAssociatedObject(self, @selector(themePath), theme, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)themePath {
    return (NSString *)objc_getAssociatedObject(self, @selector(themePath));
}

- (void)applyTheme:(NSString *)themePath {
    self.themePath = themePath;
    
    UIImage *backgroundImage = MIMAGEX(themePath, QDThemeKeywordPathImageNormal);
    if (backgroundImage) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [QDDeviceInfo screenScale]);
        [backgroundImage drawInRect:self.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.backgroundColor = [UIColor colorWithPatternImage:image];
    }
    UIColor* bgColor = MCOLORX(themePath, QDThemeKeywordPathBackgroundColor);
    if (bgColor) {
        self.backgroundColor = bgColor;
    }
}

@end
