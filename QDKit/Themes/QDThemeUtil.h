//
//  QDThemeUtil.h
//  QDKit
//
//  Created by song on 14/10/19.
//  Copyright (c) 2014年 Personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "QDThemeMgr.h"

CG_INLINE
UIColor* getColorOrClearColor(UIColor* color)
{
    if (color==nil) {
        return [UIColor clearColor];
    }
    return color;
}

#define QDColor( colorName )  getColorOrClearColor([QDThemeUtil parseColorFromValues:[NSArray arrayWithObject:colorName]])
#define QDArray(selector,property) [THEME_MGR getValueOfProperty:property forSeletor:selector]
#define QDArrayC(selector) [THEME_MGR constantsValueForKey:selector]

#define RGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBAColor(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define QDImage(image) [THEME_MGR imageNamed:image]

#define QDImageFromColor(color) [THEME_MGR imageFromColor:color]

// with selector 即从css文件中取
#define QDColorX(selector,property) getColorOrClearColor([QDThemeUtil parseColorFromValues:QDArray(selector,property)])
#define QDImageX(selector,property) [QDThemeUtil parseStrechedImageFromValues:QDArray(selector,property)]
#define QDFloat(selector,property) [QDThemeUtil parseFloatFromValues:QDArray(selector,property)]
#define QDFont(selector,property) [QDThemeUtil parseFontFromValues:QDArray(selector,property)]
#define QDRect(selector,property) [QDThemeUtil parseRectFromValues:QDArray(selector,property)]
#define QDSize(selector,property) [QDThemeUtil parseSizeFromValues:QDArray(selector,property)]
#define QDTextAlignment(selector,property) [QDThemeUtil textAlignmentFromValues:QDArray(selector,property)]
#define QDViewContentMode(selector,property) [QDThemeUtil viewContentModeFromValues:QDArray(selector,property)]
#define QDEdgeInsets(selector,property) [QDThemeUtil edgeInsetsFromValues:QDArray(selector,property)]

#define QDCacheImage(image, url) [THEME_MGR cacheImage:image forKey:url]

// with constants
#define QDColorC(selector) getColorOrClearColor([QDThemeUtil parseColorFromValues:QDArrayC(selector)])
#define QDImageC(selector) [QDThemeUtil parseStrechedImageFromValues:QDArrayC(selector)]
#define QDFloatC(selector) [QDThemeUtil parseFloatFromValues:QDArrayC(selector)]
#define QDFontC(selector) [QDThemeUtil parseFontFromValues:QDArrayC(selector)]
#define QDRectC(selector) [QDThemeUtil parseRectFromValues:QDArrayC(selector)]
#define QDSizeC(selector) [QDThemeUtil parseSizeFromValues:QDArrayC(selector)]

@interface QDThemeUtil : NSObject

+ (UIColor *)parseColorFromValues:(NSArray*)value;
+ (UIImage *)parseStrechedImageFromValues:(NSArray*)value;
+ (CGFloat)parseFloatFromValues:(NSArray*)value; //可能有dynamic值
+ (UIFont *)parseFontFromValues:(NSArray*)value; // 可能有dynamic值
+ (CGRect)parseRectFromValues:(NSArray*)value; //可能有dynamic值
+ (CGSize)parseSizeFromValues:(NSArray*)value; //可能有dynamic值

+ (NSTextAlignment)textAlignmentFromValues:(NSArray*)value;
+ (UIViewContentMode)viewContentModeFromValues:(NSArray*) value;
+ (UIEdgeInsets)edgeInsetsFromValues:(NSArray*) value;
@end
