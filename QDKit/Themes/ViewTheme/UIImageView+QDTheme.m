//
//  UIImageView+QDTheme.m
//  QDKit
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "UIImageView+QDTheme.h"
#import "UIView+QDTheme.h"
#import "QDViewTheme.h"
#import "QDThemeUtil.h"

@interface UIImageView ()

@property (nonatomic, copy) NSString * qd_themePath;

@end

@implementation UIImageView (QDTheme)

- (void)qd_applyTheme:(NSString *)themePath {

    if ([self.qd_themePath isEqualToString:themePath]) return;
    self.qd_themePath = themePath;
    
    //  Set BackgroundColor
    self.backgroundColor = QDColorX(themePath, QDThemeKeywordPathBackgroundColor);
    
    //  Set Image
    self.image = QDImageX(themePath, QDThemeKeywordPathImageNormal);
    
    //  Set Highlighted Image
    self.highlightedImage = QDImageX(themePath, QDThemeKeywordPathImageHighlighted);
    
    //  Set ContentMode
    self.contentMode = QDViewContentMode(themePath, QDThemeKeywordAttributeContentModel);
    
    self.clipsToBounds = [[QDArray(themePath, QDThemeKeywordClipsToBounds) firstObject] boolValue];
    
    if ([[QDArray(themePath, QDThemeKeywordAttributeSizeToFit) firstObject] boolValue]) {
        [self sizeToFit];
    }
}

@end
