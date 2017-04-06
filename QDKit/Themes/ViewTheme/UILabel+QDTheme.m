//
//  UILabel+QDTheme.m
//  QDKit
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "UILabel+QDTheme.h"
#import "UIView+QDTheme.h"
#import "QDViewTheme.h"
#import "QDThemeUtil.h"

@interface UILabel ()

@property (nonatomic, copy) NSString *qd_themePath;

@end

@implementation UILabel (QDTheme)

- (void)qd_applyTheme:(NSString *)themePath {
    
    if ([self.qd_themePath isEqualToString:themePath]) return;
    self.qd_themePath = themePath;

        //  Set BackgroundColor
    self.backgroundColor = QDColorX(themePath, QDThemeKeywordPathBackgroundColor);
    
    //  Set TextColor
    self.textColor = QDColorX(themePath, QThemeKeywrodPathTextColorNormal);
    
    //  Set TextHighlightedColor
    UIColor* hlColor = QDColorX(themePath, QDThemeKeywordPathTextColorHighlighted);
    if (hlColor) {
        self.highlightedTextColor = hlColor;
    } else {
        self.highlightedTextColor = self.textColor;
    }

    //  Set TextShadowColor
    self.shadowColor = QDColorX(themePath, QDThemeKeywordPathTextColorShadow);
    
    //  Set TextShadowOffset
    self.shadowOffset = QDSize(themePath, QDThemeKeywordPathTextShadowOffset);
    
    self.font = QDFont(themePath, QDThemeKeywordPathTextFont);
    
    //  Set TextAlignment
    self.textAlignment = QDTextAlignment(themePath, QDThemeKeywordAttributeTextAlignment);
    
    //  Set
    self.lineBreakMode = NSLineBreakByTruncatingTail;
    
    //  Set TextLineNumber
    self.numberOfLines = QDFloat(themePath, QDThemeKeywordAttributeTextLineNumber);

    if ([[QDArray(themePath, QDThemeKeywordAttributeSizeToFit) firstObject] boolValue]) {
        [self sizeToFit];
    }
}

@end
