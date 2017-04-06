//
//  NSString+QDTheme.h
//  QDKit
//
//  Created by song on 12/1/15.
//  Copyright (c) 2017 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (QDTheme)

- (CGFloat) qd_widthWithTheme:(NSString *)themePath;

- (CGFloat) qd_heightWithTheme:(NSString *)themePath constrainedWidth:(CGFloat)width;

- (CGSize) qd_sizeWithTheme:(NSString *)themePath constrainedWidth:(CGFloat)width;

- (int) qd_lineWithTheme:(NSString *)themePath constrainedWidth:(CGFloat)width;
@end
