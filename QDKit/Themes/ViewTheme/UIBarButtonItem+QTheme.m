//
//  UIBarButtonItem+QTheme.m
//  BusTrack
//
//  Created by song on 15/12/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "UIBarButtonItem+QTheme.h"
#import "UIView+QTheme.h"
#import "QDViewTheme.h"
#import "UIButton+QTheme.h"

@interface QNavigationBackgroundView : UIView

@end

@implementation QNavigationBackgroundView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    /* Prevent other buttons do not respond. */
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    } else {
        return hitView;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return YES;
}

@end

@implementation UIBarButtonItem (QTheme)

+ (UIBarButtonItem *) barbuttonItemWithTheme:(NSString *)theme target:(id)target action:(SEL)selector {
    return [UIBarButtonItem barbuttonItemWithTheme:theme target:target action:selector alignmentLeft:NO];
}

+ (UIBarButtonItem *) barbuttonItemWithTheme:(NSString *)theme target:(id)target action:(SEL)selector alignmentLeft:(BOOL)left {
    return [UIBarButtonItem barbuttonItemWithTheme:theme title:nil target:target action:selector alignmentLeft:left];
}

+ (UIBarButtonItem *) barbuttonItemWithTheme:(NSString *)theme title:(NSString *)title target:(id)target action:(SEL)selector alignmentLeft:(BOOL)left {
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 32)];
    [button applyTheme:theme];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    if (title.length) {
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateDisabled];
        [button setTitle:title forState:UIControlStateHighlighted];
    }
    
    QNavigationBackgroundView *backgroundView = [[QNavigationBackgroundView alloc] initWithFrame:button.frame];
    backgroundView.bounds = CGRectOffset(backgroundView.bounds, left ? 0 : 0 , 0);
    [backgroundView addSubview:button];
        
    return [[UIBarButtonItem alloc] initWithCustomView:backgroundView];
}

+ (UIBarButtonItem *) modalBarbuttonItemWithTheme:(NSString *)theme title:(NSString *)title target:(id)target action:(SEL)selector alignmentLeft:(BOOL)left {
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 32)];
    [button applyTheme:theme];
    
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    if (title.length) {
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateDisabled];
        [button setTitle:title forState:UIControlStateHighlighted];
    }
    
    QNavigationBackgroundView *backgroundView = [[QNavigationBackgroundView alloc] initWithFrame:button.frame];
    backgroundView.bounds = CGRectOffset(backgroundView.bounds, left ? -10 : 10 , 2);
    [backgroundView addSubview:button];
    
    return [[UIBarButtonItem alloc] initWithCustomView:backgroundView];
}

@end
