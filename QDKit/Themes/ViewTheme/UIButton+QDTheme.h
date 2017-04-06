//
//  UIButton+QDTheme.h
//  QDKit
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (QDTheme)

- (void)qd_applyTheme:(NSString *)themePath;

- (void)qd_centerImageAndTitle:(float)spacing;
- (void)qd_centerImageAndTitle;
@end
