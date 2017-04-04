//
//  UIImageView+QTheme.m
//  BusTrack
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "UIImageView+QTheme.h"
#import "UIView+QTheme.h"
#import "QDViewTheme.h"
#import "QDThemeUtil.h"

@interface UIImageView ()

@property (nonatomic, copy) NSString * themePath;

@end

@implementation UIImageView (QTheme)

- (void)applyTheme:(NSString *)themePath {

    if ([self.themePath isEqualToString:themePath]) return;
    
    self.themePath = themePath;
    
    //  Set BackgroundColor
    self.backgroundColor = MCOLORX(themePath, QDThemeKeywordPathBackgroundColor);
    
    //  Set Image
    self.image = MIMAGEX(themePath, QDThemeKeywordPathImageNormal);
    
    //  Set Highlighted Image
    self.highlightedImage = MIMAGEX(themePath, QDThemeKeywordPathImageHighlighted);
    
    //  Set ContentMode
    self.contentMode = MViewContentMode(themePath, QDThemeKeywordAttributeContentModel);
    
    self.clipsToBounds = [[MARRAY(themePath, QDThemeKeywordClipsToBounds) firstObject] boolValue];
    
    if ([[MARRAY(themePath, QDThemeKeywordAttributeSizeToFit) firstObject] boolValue]) {
        [self sizeToFit];
    }
}

@end
