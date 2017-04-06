//
//  QDViewTheme.h
//  QDKit
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>

// Parent theme
extern NSString * const QDThemeKeywordAttributeSuper;

// Selector
extern NSString * const QDThemeKeywordAttributeSelector;

// UIEdgeInset
extern NSString * const QDThemeKeywordAttributeTop;
extern NSString * const QDThemeKeywordAttributeLeft;
extern NSString * const QDThemeKeywordAttributeBottom;
extern NSString * const QDThemeKeywordAttributeRight;

// UIColor
extern NSString * const QDThemeKeywordPathBackgroundColor;
extern NSString * const QThemeKeywrodPathTextColorNormal;
extern NSString * const QDThemeKeywordPathTextColorShadow;
extern NSString * const QDThemeKeywordPathTextColorSelected;
extern NSString * const QDThemeKeywordPathTextColorHighlighted;
extern NSString * const QDThemeKeywordPathTextColorDisabled;
extern NSString * const QDThemeKeywordPathTextColorDisabledShadow;

// UIFont
extern NSString * const QDThemeKeywordAttributeFontBold;
extern NSString * const QDThemeKeywordAttributeSize;
extern NSString * const QDThemeKeywordPathTextFont;

// UIButton
extern NSString * const QDThemeKeywordPathButton;
extern NSString * const QDThemeKeywordPathTitleEdgeInsets;
extern NSString * const QDThemeKeywordPathImageEdgeInsets;
extern NSString * const QDThemeKeywordAttributeUseImage;
extern NSString * const QDThemeKeywordSwapImageAndTitle;

// Frame
extern NSString * const QDThemeKeywordAttributeWidth;
extern NSString * const QDThemeKeywordAttributeHeight;
extern NSString * const QDThemeKeywordPathTextShadowOffset;

// Image
extern NSString * const QDThemeKeywordAttributeImageName;
extern NSString * const QDThemeKeywordAttributeLeftCapWidth;
extern NSString * const QDThemeKeywordAttributeTopCapWidth;
extern NSString * const QDThemeKeywordPathCapEdgeInsets;
extern NSString * const QDThemeKeywordPathImageNormal;
extern NSString * const QDThemeKeywordPathImageDisabled;
extern NSString * const QDThemeKeywordPathImageHighlighted;
extern NSString * const QDThemeKeywordPathImageSelected;
extern NSString * const QDThemeKeywordPathIconNormal;
extern NSString * const QDThemeKeywordPathIconHighlighted;
extern NSString * const QDThemeKeywordClipsToBounds;

// Text
extern NSString * const QDThemeKeywordAttributeTextLineNumber;
extern NSString * const QDThemeKeywordAttributeTextLineBreakMode;
extern NSString * const QDThemeKeywordAttributeTextAlignment;

// View
extern NSString * const QDThemeKeywordAttributeContentModel;
extern NSString * const QDThemeKeywordAttributeSizeToFit;

@interface QDViewTheme : NSObject

@end
