//
//  QDThemeUtil.m
//  BusTrack
//
//  Created by song on 14/10/19.
//  Copyright (c) 2014年 droison. All rights reserved.
//

#import "QDThemeUtil.h"
#import "QDDeviceInfo.h"

#define CONSTANTS_THEME_DYNAMIC @"dynamic"

@implementation QDThemeUtil

+(UIColor*) parseColorFromValues:(NSArray*)cssValues {
    UIColor* anColor = nil;
    
    BOOL validCss =	   [cssValues count] == 1
    || [cssValues count] == 5    // rgb( x x x )
    || [cssValues count] == 6;   // rgba( x x x x )
    if ( !validCss )
    {
        return nil;
    }
    
    if ([cssValues count] == 1) {
        NSString* cssString = [cssValues firstObject];
        
        if ([cssString characterAtIndex:0] == '#') {
            unsigned long colorValue = 0;
            float alpha = 1;
            // #FFF
            if ([cssString length] == 4) {
                colorValue = strtol([cssString UTF8String] + 1, nil, 16);
                colorValue = ((colorValue & 0xF00) << 12) | ((colorValue & 0xF00) << 8)
                | ((colorValue & 0xF0) << 8) | ((colorValue & 0xF0) << 4)
                | ((colorValue & 0xF) << 4) | (colorValue & 0xF);
                
                // #FFFFFF
            } else if ([cssString length] == 7) {
                colorValue = strtol([cssString UTF8String] + 1, nil, 16);
            } else if ([cssString length] == 9) {
                alpha = strtol([[cssString substringFromIndex:7] UTF8String],nil,16) / 255.0;
                colorValue = strtol([[cssString substringToIndex:7] UTF8String] + 1, nil, 16);
            }
            
            anColor = RGBACOLOR(((colorValue & 0xFF0000) >> 16),
                                ((colorValue & 0xFF00) >> 8),
                                (colorValue & 0xFF),
                                alpha
                                );
            
        } else {
            anColor = nil;
        }
    } else if ([cssValues count] == 5 && [[cssValues firstObject] isEqualToString:@"rgb("]) {
        // rgb( x x x )
        anColor = RGBCOLOR([[cssValues objectAtIndex:1] floatValue],
                           [[cssValues objectAtIndex:2] floatValue],
                           [[cssValues objectAtIndex:3] floatValue]);
        
    } else if ([cssValues count] == 6 && [[cssValues firstObject] isEqualToString:@"rgba("]) {
        // rgba( x x x x )
        anColor = RGBACOLOR([[cssValues objectAtIndex:1] floatValue],
                            [[cssValues objectAtIndex:2] floatValue],
                            [[cssValues objectAtIndex:3] floatValue],
                            [[cssValues objectAtIndex:4] floatValue]);
    }
    
    return anColor;
}

+(UIFont*) parseFontFromValues:(NSArray*)value
{
    if (value==nil||[value count]==0) {
        return [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    
    NSUInteger count = value.count;
    
    NSInteger fontSize = [[value firstObject] integerValue];
    if (fontSize <= 5) {
        fontSize = 5;
    }
    
    if (count > 1 && [[value lastObject] isEqualToString:CONSTANTS_THEME_DYNAMIC]) {
        fontSize = (int) (fontSize * [QDThemeUtil themeScale]);
        count--;
    }
    
    if (count > 1) {
        if ([[value objectAtIndex:1] isEqualToString:@"bold"]) {
            return [UIFont boldSystemFontOfSize:fontSize];
        }else if([[value objectAtIndex:1] isEqualToString:@"italic"]){
            return [UIFont italicSystemFontOfSize:fontSize];
        }else{
            UIFont* font = [UIFont fontWithName:[value objectAtIndex:1] size:fontSize];
            return font?:[UIFont systemFontOfSize:fontSize];
        }
    }
    
    return [UIFont systemFontOfSize:fontSize];
}

+(CGFloat) parseFloatFromValues:(NSArray*)value
{
    CGFloat floatValue = [[value firstObject] floatValue];
    if ([[value lastObject] isEqualToString:CONSTANTS_THEME_DYNAMIC]) {
        floatValue *= [QDThemeUtil themeScale];
    }
   return floatValue;
}

+(UIImage*) parseStrechedImageFromValues:(NSArray*)value
{
    if ([value count]==1) {
        return MIMAGE([value firstObject]);
    }
    if ([value count]==3) {
        UIImage* image = MIMAGE([value firstObject]);
        //		MMDebug(@"image:%@ %@ %@" , [value firstObject] , [value objectAtIndex:1] , [value objectAtIndex:2] ) ;
        return [image stretchableImageWithLeftCapWidth:[[value objectAtIndex:1] integerValue] topCapHeight:[[value objectAtIndex:2] integerValue]];
    }
    return nil;
}

+(CGRect) parseRectFromValues:(NSArray*)value
{
    if ([[value lastObject] isEqualToString:CONSTANTS_THEME_DYNAMIC]) {
        if (value.count == 5) {
            CGFloat scale = [QDThemeUtil themeScale];
            return CGRectMake((int)([[value objectAtIndex:0]floatValue] * scale),
                              (int)([[value objectAtIndex:1]floatValue] * scale),
                              (int)([[value objectAtIndex:2]floatValue] * scale),
                              (int)([[value objectAtIndex:3]floatValue] * scale));
        }
    } else if (value.count==4) {
        return CGRectMake([[value objectAtIndex:0]integerValue], [[value objectAtIndex:1]integerValue], [[value objectAtIndex:2]integerValue],[[value objectAtIndex:3]integerValue]);
    }
    return CGRectZero;
}

+(CGSize) parseSizeFromValues:(NSArray*)value {
    if ([[value lastObject] isEqualToString:CONSTANTS_THEME_DYNAMIC]) {
        if (value.count == 3) {
            CGFloat scale = [QDThemeUtil themeScale];
            return CGSizeMake((int)([[value objectAtIndex:0]floatValue] * scale),
                              (int)([[value objectAtIndex:1]floatValue] * scale));
        }
    } else if (value.count==2) {
        return CGSizeMake([[value objectAtIndex:0]integerValue], [[value objectAtIndex:1]integerValue]);
    }
    return CGSizeZero;
}

+ (NSTextAlignment) textAlignmentFromValues:(NSArray*)value {
    if (value && value.count > 0) {
        NSDictionary *lookupTable =
        @{
          @"Left":@(NSTextAlignmentLeft),
          @"Right":@(NSTextAlignmentRight),
          @"Center":@(NSTextAlignmentCenter),
          };
        
        NSNumber *number = [lookupTable objectForKey:[value firstObject]];
        if (number)
        {
            return (NSTextAlignment)[number integerValue];
        }
    }
    return NSTextAlignmentLeft;
}

+ (UIViewContentMode)viewContentModeFromValues:(NSArray*) value{
    
    NSDictionary *lookupTable =
    @{
      @"ScaleToFill":@(UIViewContentModeScaleToFill),
      @"ScaleAspectFit":@(UIViewContentModeScaleAspectFit),
      @"ScaleAspectFill":@(UIViewContentModeScaleAspectFill),
      @"Redraw":@(UIViewContentModeRedraw),
      @"Center":@(UIViewContentModeCenter),
      @"Top":@(UIViewContentModeTop),
      @"Bottom":@(UIViewContentModeBottom),
      @"Left":@(UIViewContentModeLeft),
      @"Right":@(UIViewContentModeRight),
      @"TopLeft":@(UIViewContentModeTopLeft),
      @"TopRight":@(UIViewContentModeTopRight),
      @"BottomLeft":@(UIViewContentModeBottomLeft),
      @"BottomRight":@(UIRectCornerBottomRight),
      };
    
    NSNumber *number = [lookupTable objectForKey:[value firstObject]];
    
    if (number) return (UIViewContentMode)[number integerValue];
    
    return UIViewContentModeScaleToFill;
}

+ (UIEdgeInsets)edgeInsetsFromValues:(NSArray*) value {
    if ([[value lastObject] isEqualToString:CONSTANTS_THEME_DYNAMIC]) {
        if (value.count == 5) {
            CGFloat scale = [QDThemeUtil themeScale];
            return UIEdgeInsetsMake((int)([[value objectAtIndex:0]floatValue] * scale),
                              (int)([[value objectAtIndex:1]floatValue] * scale),
                              (int)([[value objectAtIndex:2]floatValue] * scale),
                              (int)([[value objectAtIndex:3]floatValue] * scale));
        }
    } else if (value.count==4) {
        return UIEdgeInsetsMake([[value objectAtIndex:0]integerValue], [[value objectAtIndex:1]integerValue], [[value objectAtIndex:2]integerValue],[[value objectAtIndex:3]integerValue]);
    }
    return UIEdgeInsetsZero;
}

+ (CGFloat) themeScale {
    CGFloat scale = [QDDeviceInfo screenWidth]/375; // iPhone下只要写了dynamic 就认为按照iPhone6的视觉稿出图做放缩
    return scale;
}
@end
