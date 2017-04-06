//
//  UIView+QDTheme.m
//  QDKit
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "UIView+QDTheme.h"
#import "QDThemeUtil.h"
#import <objc/runtime.h>
#import "QDDeviceInfo.h"

@interface UIView ()

@property (nonatomic, copy) NSString *qd_themePath;

@end

@implementation UIView (QDTheme)

- (void)setQd_themePath:(NSString *)theme {
    objc_setAssociatedObject(self, @selector(qd_themePath), theme, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)qd_themePath {
    return (NSString *)objc_getAssociatedObject(self, @selector(qd_themePath));
}

- (void)qd_applyTheme:(NSString *)themePath {
    if ([self.qd_themePath isEqualToString:themePath]) return;
    self.qd_themePath = themePath;
    
    UIImage *backgroundImage = QDImageX(themePath, QDThemeKeywordPathImageNormal);
    if (backgroundImage) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [QDDeviceInfo screenScale]);
        [backgroundImage drawInRect:self.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.backgroundColor = [UIColor colorWithPatternImage:image];
    }
    UIColor* bgColor = QDColorX(themePath, QDThemeKeywordPathBackgroundColor);
    if (bgColor) {
        self.backgroundColor = bgColor;
    }
}

@end
