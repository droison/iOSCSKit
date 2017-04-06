//
//  UIView+QDTheme.h
//  QDKit
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDViewTheme.h"
#import <UIKit/UIKit.h>

@interface UIView (QDTheme)

@property (nonatomic, copy, readonly) NSString *qd_themePath;

- (void) qd_applyTheme:(NSString *)themePath;

@end
