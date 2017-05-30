//
//  UIButton+QDTheme.m
//  QDKit
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "UIButton+QDTheme.h"
#import "UIView+QDTheme.h"
#import "QDViewTheme.h"
#import "QDThemeUtil.h"

@interface UIButton ()

@property (nonatomic, copy) NSString *qd_themePath;

@end

@implementation UIButton (QDTheme)

- (void)qd_applyTheme:(NSString *)themePath {
    
    if ([self.qd_themePath isEqualToString:themePath]) return;
    self.qd_themePath = themePath;
    
    //  Set BackgroundColor
    self.backgroundColor = QDColorX(themePath, QDThemeKeywordPathBackgroundColor);
    
    //  Set Normal Title Color
    [self setTitleColor:QDColorX(themePath, QThemeKeywrodPathTextColorNormal) forState:UIControlStateNormal];
    //  Set Title ShadowColor
    [self setTitleShadowColor:QDColorX(themePath, QDThemeKeywordPathTextColorShadow) forState:UIControlStateNormal];
    
    //  Set Selected Title Color
    [self setTitleColor:QDColorX(themePath, QDThemeKeywordPathTextColorSelected) forState:UIControlStateSelected];
    //  Set Highlighted Title Color
    [self setTitleColor:QDColorX(themePath, QDThemeKeywordPathTextColorHighlighted) forState:UIControlStateHighlighted];
    
    //  Set Disabled Title Color
    [self setTitleColor:QDColorX(themePath, QDThemeKeywordPathTextColorDisabled) forState:UIControlStateDisabled];
    //  Set Disabled Title Shadow Color
    [self setTitleShadowColor:QDColorX(themePath, QDThemeKeywordPathTextColorShadow) forState:UIControlStateDisabled];
    
    //  Set Title ShadowOffset
    [self.titleLabel setShadowOffset:QDSize(themePath, QDThemeKeywordPathTextShadowOffset)];
    //  Set Title Textfont
    
    self.titleLabel.font = QDFont(themePath, QDThemeKeywordPathTextFont);
    
    //  Set Title Edge Insets if any
    UIEdgeInsets titleEdgeInsets = QDEdgeInsets(themePath, QDThemeKeywordPathTitleEdgeInsets);
    if (!UIEdgeInsetsEqualToEdgeInsets(titleEdgeInsets, UIEdgeInsetsZero)) {
        self.titleEdgeInsets = titleEdgeInsets;
    }
    
    if ([[QDArray(themePath, QDThemeKeywordAttributeUseImage) firstObject] boolValue]) { //表示图标文字分开那种
        // Set Normal BackgroundImage
        [self setImage:QDImageX(themePath,QDThemeKeywordPathImageNormal) forState:UIControlStateNormal];
        // Set Highlighted BackgroundImage
        [self setImage:QDImageX(themePath,QDThemeKeywordPathImageHighlighted) forState:UIControlStateHighlighted];
        //  Set Disabled BackgroundImage
        [self setImage:QDImageX(themePath,QDThemeKeywordPathImageDisabled) forState:UIControlStateDisabled];
        //  Set Selected BackgroundImage
        [self setImage:QDImageX(themePath,QDThemeKeywordPathImageSelected) forState:UIControlStateSelected];
        // Set ImageEdgeInsets if any
        UIEdgeInsets imageInsets = QDEdgeInsets(themePath, QDThemeKeywordPathImageEdgeInsets);
        if (!UIEdgeInsetsEqualToEdgeInsets(imageInsets, UIEdgeInsetsZero)) {
            self.imageEdgeInsets = imageInsets;
        }
    } else {
        // Set Normal BackgroundImage
        [self setImage:QDImageX(themePath,QDThemeKeywordPathIconNormal) forState:UIControlStateNormal];
        // Set Highlighted BackgroundImage
        [self setImage:QDImageX(themePath,QDThemeKeywordPathIconHighlighted) forState:UIControlStateHighlighted];
        // Set Normal Background Imgae
        [self setBackgroundImage:QDImageX(themePath,QDThemeKeywordPathImageNormal) forState:UIControlStateNormal];
        // Set Highlighted Background Image
        [self setBackgroundImage:QDImageX(themePath,QDThemeKeywordPathImageHighlighted) forState:UIControlStateHighlighted];
        //  Set Disabled BackgroundImage
        [self setBackgroundImage:QDImageX(themePath,QDThemeKeywordPathImageDisabled) forState:UIControlStateDisabled];
        //  Set Selected BackgroundImage
        [self setBackgroundImage:QDImageX(themePath,QDThemeKeywordPathImageSelected) forState:UIControlStateSelected];
    }
    
    if ([[QDArray(themePath, QDThemeKeywordAttributeSizeToFit) firstObject] boolValue]) {
        [self sizeToFit];
    }
    
    if ([[QDArray(themePath, QDThemeKeywordSwapImageAndTitle) firstObject] boolValue]) {
        self.transform = CGAffineTransformScale(self.transform, -1.0f, 1.0f);
        self.titleLabel.transform = CGAffineTransformScale(self.titleLabel.transform, -1.0f, 1.0f);
        self.imageView.transform = CGAffineTransformScale(self.imageView.transform, -1.0f, 1.0f);
    }
}

- (void)qd_centerImageAndTitle:(float)spacing {
    CGFloat insetAmount = spacing / 2.0;
    self.imageEdgeInsets = UIEdgeInsetsMake(0, -insetAmount, 0, insetAmount);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, -insetAmount);
    self.contentEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, insetAmount);
}

- (void)qd_centerImageAndTitle
{
    const int DEFAULT_SPACING = 6.0f;
    [self qd_centerImageAndTitle:DEFAULT_SPACING];
}
@end
