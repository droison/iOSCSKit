//
//  UIImage+Color.m
//  QDKit
//
//  Created by song on 14/10/19.
//  Copyright (c) 2014年 Personal. All rights reserved.
//

#import "UIImage+QDColor.h"

@implementation UIImage(QDColor)

+(UIImage *) qd_imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    if( &UIGraphicsBeginImageContextWithOptions != NULL ) {
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    }else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
        UIGraphicsBeginImageContext( rect.size ) ;
#pragma clang diagnostic pop
    }
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
