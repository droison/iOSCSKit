//
//  UILabel+QTheme.m
//  BusTrack
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "UILabel+QTheme.h"
#import "UIView+QTheme.h"
#import "QDViewTheme.h"
#import "QDThemeUtil.h"

@interface UILabel ()

@property (nonatomic, copy) NSString *themePath;

@end

@implementation UILabel (QTheme)

- (void)applyTheme:(NSString *)themePath {
    
    if ([self.themePath isEqualToString:themePath]) return;
    if ([themePath hasSuffix:@"Read"]) {
        themePath = [themePath substringToIndex:themePath.length-4];
    }
    self.themePath = themePath;

        //  Set BackgroundColor
    self.backgroundColor = MCOLORX(themePath, QDThemeKeywordPathBackgroundColor);
    
    //  Set TextColor
    self.textColor = MCOLORX(themePath, QThemeKeywrodPathTextColorNormal);
    
    //  Set TextHighlightedColor
    UIColor* hlColor = MCOLORX(themePath, QDThemeKeywordPathTextColorHighlighted);
    if (hlColor) {
        self.highlightedTextColor = hlColor;
    } else {
        self.highlightedTextColor = self.textColor;
    }

    //  Set TextShadowColor
    self.shadowColor = MCOLORX(themePath, QDThemeKeywordPathTextColorShadow);
    
    //  Set TextShadowOffset
    self.shadowOffset = MSIZEX(themePath, QDThemeKeywordPathTextShadowOffset);
    
    self.font = MFONT(themePath, QDThemeKeywordPathTextFont);
    
    //  Set TextAlignment
    self.textAlignment = MTextAlignment(themePath, QDThemeKeywordAttributeTextAlignment);
    
    //  Set
    self.lineBreakMode = NSLineBreakByTruncatingTail;
    
    //  Set TextLineNumber
    self.numberOfLines = MFLOAT(themePath, QDThemeKeywordAttributeTextLineNumber);

    if ([[MARRAY(themePath, QDThemeKeywordAttributeSizeToFit) firstObject] boolValue]) {
        [self sizeToFit];
    }
}

@end
