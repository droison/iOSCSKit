//
//  UIButton+QTheme.h
//  BusTrack
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (QTheme)

- (void)applyTheme:(NSString *)themePath;

- (void)centerImageAndTitle:(float)spacing;
- (void)centerImageAndTitle;
@end
