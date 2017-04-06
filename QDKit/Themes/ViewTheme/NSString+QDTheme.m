//
//  NSString+QDTheme.m
//  QDKit
//
//  Created by song on 12/1/15.
//  Copyright (c) 2017 Personal. All rights reserved.
//

#import "NSString+QDTheme.h"
#import "QDThemeUtil.h"
#import "QDViewTheme.h"

@implementation NSString (QDTheme)

- (CGFloat) qd_widthWithTheme:(NSString *)themePath {
    
    UIFont *font = QDFont(themePath, QDThemeKeywordPathTextFont);
    NSDictionary *attributeDict = @{NSFontAttributeName:font};
    
    return ceilf([self sizeWithAttributes:attributeDict].width);
}

- (CGFloat) qd_heightWithTheme:(NSString *)themePath constrainedWidth:(CGFloat)width {
    return ceilf([self qd_sizeWithTheme:themePath constrainedWidth:width].height);
}

- (CGSize) qd_sizeWithTheme:(NSString *)themePath constrainedWidth:(CGFloat)width {
    
    UIFont *font = QDFont(themePath, QDThemeKeywordPathTextFont);
    CGFloat lineHeight = font.lineHeight;
    NSUInteger lineNumber = QDFloat(themePath, QDThemeKeywordAttributeTextLineNumber);
    
    NSDictionary *attributeDict = @{NSFontAttributeName : font,
                                    };
    
    CGSize size = [self boundingRectWithSize:CGSizeMake(width, lineNumber ? (lineNumber * lineHeight) : CGFLOAT_MAX)
                                     options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine)
                                  attributes:attributeDict
                                     context:nil].size;
    
    return size;
}

- (int) qd_lineWithTheme:(NSString *)themePath constrainedWidth:(CGFloat)width {
    CGFloat height = [self qd_heightWithTheme:themePath constrainedWidth:width];
    UIFont *font = QDFont(themePath, QDThemeKeywordPathTextFont);
    CGFloat lineHeight = font.lineHeight;
    return height/lineHeight;
}
@end

