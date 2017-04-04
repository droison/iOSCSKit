//
//  UIButton+QTheme.m
//  BusTrack
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "UIButton+QTheme.h"
#import "UIView+QTheme.h"
#import "QDViewTheme.h"
#import "QDThemeUtil.h"

@interface UIButton ()

@property (nonatomic, copy) NSString *themePath;

@end

@implementation UIButton (QTheme)

- (void)applyTheme:(NSString *)themePath {
    
    if ([self.themePath isEqualToString:themePath]) return;
    
    if ([themePath hasSuffix:@"Read"]) {
        themePath = [themePath substringToIndex:themePath.length-4];
    }
    self.themePath = themePath;
    
    //  Set BackgroundColor
    self.backgroundColor = MCOLORX(themePath, QDThemeKeywordPathBackgroundColor);
    
    //  Set Normal Title Color
    [self setTitleColor:MCOLORX(themePath, QThemeKeywrodPathTextColorNormal) forState:UIControlStateNormal];
    //  Set Title ShadowColor
    [self setTitleShadowColor:MCOLORX(themePath, QDThemeKeywordPathTextColorShadow) forState:UIControlStateNormal];
    
    //  Set Selected Title Color
    [self setTitleColor:MCOLORX(themePath, QDThemeKeywordPathTextColorSelected) forState:UIControlStateSelected];
    //  Set Highlighted Title Color
    [self setTitleColor:MCOLORX(themePath, QDThemeKeywordPathTextColorHighlighted) forState:UIControlStateHighlighted];
    
    //  Set Disabled Title Color
    [self setTitleColor:MCOLORX(themePath, QDThemeKeywordPathTextColorDisabled) forState:UIControlStateDisabled];
    //  Set Disabled Title Shadow Color
    [self setTitleShadowColor:MCOLORX(themePath, QDThemeKeywordPathTextColorShadow) forState:UIControlStateDisabled];
    
    //  Set Title ShadowOffset
    [self.titleLabel setShadowOffset:MSIZEX(themePath, QDThemeKeywordPathTextShadowOffset)];
    //  Set Title Textfont
    
    self.titleLabel.font = MFONT(themePath, QDThemeKeywordPathTextFont);
    
    //  Set Title Edge Insets if any
    UIEdgeInsets titleEdgeInsets = MEdgeInsets(themePath, QDThemeKeywordPathTitleEdgeInsets);
    if (!UIEdgeInsetsEqualToEdgeInsets(titleEdgeInsets, UIEdgeInsetsZero)) {
        self.titleEdgeInsets = titleEdgeInsets;
    }
    
    if ([[MARRAY(themePath, QDThemeKeywordAttributeUseImage) firstObject] boolValue]) { //表示图标文字分开那种
        // Set Normal BackgroundImage
        [self setImage:MIMAGEX(themePath,QDThemeKeywordPathImageNormal) forState:UIControlStateNormal];
        // Set Highlighted BackgroundImage
        [self setImage:MIMAGEX(themePath,QDThemeKeywordPathImageHighlighted) forState:UIControlStateHighlighted];
        //  Set Disabled BackgroundImage
        [self setImage:MIMAGEX(themePath,QDThemeKeywordPathImageDisabled) forState:UIControlStateDisabled];
        //  Set Selected BackgroundImage
        [self setImage:MIMAGEX(themePath,QDThemeKeywordPathImageSelected) forState:UIControlStateSelected];
        // Set ImageEdgeInsets if any
        UIEdgeInsets imageInsets = MEdgeInsets(themePath, QDThemeKeywordPathImageEdgeInsets);
        if (!UIEdgeInsetsEqualToEdgeInsets(imageInsets, UIEdgeInsetsZero)) {
            self.imageEdgeInsets = imageInsets;
        }
    } else {
        // Set Normal BackgroundImage
        [self setImage:MIMAGEX(themePath,QDThemeKeywordPathIconNormal) forState:UIControlStateNormal];
        // Set Highlighted BackgroundImage
        [self setImage:MIMAGEX(themePath,QDThemeKeywordPathIconHighlighted) forState:UIControlStateHighlighted];
        // Set Normal Background Imgae
        [self setBackgroundImage:MIMAGEX(themePath,QDThemeKeywordPathImageNormal) forState:UIControlStateNormal];
        // Set Highlighted Background Image
        [self setBackgroundImage:MIMAGEX(themePath,QDThemeKeywordPathImageHighlighted) forState:UIControlStateHighlighted];
        //  Set Disabled BackgroundImage
        [self setBackgroundImage:MIMAGEX(themePath,QDThemeKeywordPathImageDisabled) forState:UIControlStateDisabled];
        //  Set Selected BackgroundImage
        [self setBackgroundImage:MIMAGEX(themePath,QDThemeKeywordPathImageSelected) forState:UIControlStateSelected];
    }
    
    if ([[MARRAY(themePath, QDThemeKeywordAttributeSizeToFit) firstObject] boolValue]) {
        [self sizeToFit];
    }
    
    if ([[MARRAY(themePath, QDThemeKeywordSwapImageAndTitle) firstObject] boolValue]) {
        self.transform = CGAffineTransformScale(self.transform, -1.0f, 1.0f);
        self.titleLabel.transform = CGAffineTransformScale(self.titleLabel.transform, -1.0f, 1.0f);
        self.imageView.transform = CGAffineTransformScale(self.imageView.transform, -1.0f, 1.0f);
    }
}

- (void)centerImageAndTitle:(float)spacing
{
    // get the size of the elements here for readability
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    // get the height they will take up as a unit
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    // raise the image and push it right to center it
    self.imageEdgeInsets = UIEdgeInsetsMake( - (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    
    // lower the text and push it left to center it
    self.titleEdgeInsets = UIEdgeInsetsMake( 0.0, - imageSize.width, - (totalHeight - titleSize.height), 0.0);
}

- (void)centerImageAndTitle
{
    const int DEFAULT_SPACING = 6.0f;
    [self centerImageAndTitle:DEFAULT_SPACING];
}
@end
