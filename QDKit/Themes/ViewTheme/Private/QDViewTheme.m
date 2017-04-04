//
//  QDViewTheme.m
//  BusTrack
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDViewTheme.h"

NSString * const QDThemeKeywordAttributeSuper = @"Super";
NSString * const QDThemeKeywordAttributeSelector = @"Selector";

// UIEdgeInset
NSString * const QDThemeKeywordAttributeTop = @"Top";
NSString * const QDThemeKeywordAttributeLeft = @"Left";
NSString * const QDThemeKeywordAttributeBottom = @"Bottom";
NSString * const QDThemeKeywordAttributeRight = @"Right";

// UIColor
NSString * const QDThemeKeywordPathBackgroundColor = @"BackgroundColor";
NSString * const QThemeKeywrodPathTextColorNormal = @"NormalTextColor";
NSString * const QDThemeKeywordPathTextColorShadow = @"TextShadowColor";
NSString * const QDThemeKeywordPathTextColorSelected = @"SelectedTextColor";
NSString * const QDThemeKeywordPathTextColorHighlighted = @"HighlightedTextColor";
NSString * const QDThemeKeywordPathTextColorDisabled = @"DisabledTextColor";
NSString * const QDThemeKeywordPathTextColorDisabledShadow = @"DisabledTextShadowColor";

// UIFont
NSString * const QDThemeKeywordAttributeFontBold = @"Bold";
NSString * const QDThemeKeywordAttributeSize = @"Size";
NSString * const QDThemeKeywordPathTextFont = @"TextFont";

// UIButton
NSString * const QDThemeKeywordPathButton = @"Button";
NSString * const QDThemeKeywordPathTitleEdgeInsets = @"TitleEdgeInsets";
NSString * const QDThemeKeywordPathImageEdgeInsets = @"ImageEdgeInsets";
NSString * const QDThemeKeywordAttributeUseImage = @"UseImage";
NSString * const QDThemeKeywordSwapImageAndTitle = @"SwapImageAndTitle";

// Frame
NSString * const QDThemeKeywordAttributeWidth = @"Width";
NSString * const QDThemeKeywordAttributeHeight = @"Height";
NSString * const QDThemeKeywordPathTextShadowOffset = @"TextShadowOffset";

// Image
NSString * const QDThemeKeywordAttributeImageName = @"ImageName";
NSString * const QDThemeKeywordAttributeLeftCapWidth = @"LeftCapWidth";
NSString * const QDThemeKeywordAttributeTopCapWidth = @"TopCapWidth";
NSString * const QDThemeKeywordPathCapEdgeInsets = @"CapEdgeInsets";
NSString * const QDThemeKeywordPathImageNormal = @"NormalImage";
NSString * const QDThemeKeywordPathImageDisabled = @"DisabledImage";
NSString * const QDThemeKeywordPathImageHighlighted = @"HighlightedImage";
NSString * const QDThemeKeywordPathImageSelected = @"SelectedImage";
NSString * const QDThemeKeywordPathIconNormal = @"NormalIcon";
NSString * const QDThemeKeywordPathIconHighlighted = @"HighlightedIcon";
NSString * const QDThemeKeywordClipsToBounds = @"Clip";

// Text
NSString * const QDThemeKeywordAttributeTextLineNumber = @"TextLineNumber";
NSString * const QDThemeKeywordAttributeTextLineBreakMode = @"LineBreakMode";
NSString * const QDThemeKeywordAttributeTextAlignment = @"TextAlignment";

// View
NSString * const QDThemeKeywordAttributeContentModel = @"ContentMode";
NSString * const QDThemeKeywordAttributeSizeToFit = @"SizeToFit";

@implementation QDViewTheme

@end
