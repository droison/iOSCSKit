//
//  QDThemeUtil.h
//  BusTrack
//
//  Created by song on 14/10/19.
//  Copyright (c) 2014年 droison. All rights reserved.
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

#define MCOLOR( colorName )  getColorOrClearColor([QDThemeUtil parseColorFromValues:[NSArray arrayWithObject:colorName]])
#define MARRAY(selector,property) [THEME_MGR getValueOfProperty:property forSeletor:selector]
#define MARRAYC(selector) [THEME_MGR constantsValueForKey:selector]

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define MIMAGE(image) [THEME_MGR imageNamed:image]

#define MIMAGE_FROM_COLOR(color) [THEME_MGR imageFromColor:color]

// with selector 即从css文件中取
#define MCOLORX(selector,property) getColorOrClearColor([QDThemeUtil parseColorFromValues:MARRAY(selector,property)])
#define MIMAGEX(selector,property) [QDThemeUtil parseStrechedImageFromValues:MARRAY(selector,property)]
#define MFLOAT(selector,property) [QDThemeUtil parseFloatFromValues:MARRAY(selector,property)]
#define MFONT(selector,property) [QDThemeUtil parseFontFromValues:MARRAY(selector,property)]
#define MRECT(selector,property) [QDThemeUtil parseRectFromValues:MARRAY(selector,property)]
#define MSIZEX(selector,property) [QDThemeUtil parseSizeFromValues:MARRAY(selector,property)]
#define MTextAlignment(selector,property) [QDThemeUtil textAlignmentFromValues:MARRAY(selector,property)]
#define MViewContentMode(selector,property) [QDThemeUtil viewContentModeFromValues:MARRAY(selector,property)]
#define MEdgeInsets(selector,property) [QDThemeUtil edgeInsetsFromValues:MARRAY(selector,property)]

#define MCACHEIMAGE(image, url) [THEME_MGR cacheImage:image forKey:url]

#define MCOLORC(selector) getColorOrClearColor([QDThemeUtil parseColorFromValues:MARRAYC(selector)])
#define MIMAGEC(selector) [QDThemeUtil parseStrechedImageFromValues:MARRAYC(selector)]
#define MFLOATC(selector) [QDThemeUtil parseFloatFromValues:MARRAYC(selector)]
#define MFONTC(selector) [QDThemeUtil parseFontFromValues:MARRAYC(selector)]
#define MRECTC(selector) [QDThemeUtil parseRectFromValues:MARRAYC(selector)]
#define MSIZEC(selector) [QDThemeUtil parseSizeFromValues:MARRAYC(selector)]

@interface QDThemeUtil : NSObject

+(UIColor*) parseColorFromValues:(NSArray*)value;
+(UIImage*) parseStrechedImageFromValues:(NSArray*)value;
+(CGFloat) parseFloatFromValues:(NSArray*)value; //可能有dynamic值
+(UIFont*) parseFontFromValues:(NSArray*)value; // 可能有dynamic值
+(CGRect) parseRectFromValues:(NSArray*)value; //可能有dynamic值
+(CGSize) parseSizeFromValues:(NSArray*)value; //可能有dynamic值

+ (NSTextAlignment) textAlignmentFromValues:(NSArray*)value;
+ (UIViewContentMode)viewContentModeFromValues:(NSArray*) value;
+ (UIEdgeInsets)edgeInsetsFromValues:(NSArray*) value;
@end
