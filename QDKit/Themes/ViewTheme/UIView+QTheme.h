//
//  UIView+QTheme.h
//  BusTrack
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDViewTheme.h"
#import <UIKit/UIKit.h>

@interface UIView (QTheme)

@property (nonatomic, copy, readonly) NSString *themePath;

- (void) applyTheme:(NSString *)themePath;

@end
