//
//  QDKeyCommands.h
//  QDKit
//
//  Created by SongChai on 2017/4/2.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QDKeyCommands : NSObject
+ (instancetype)sharedInstance;

/**
 * Register a single-press keyboard command.
 */
- (void)registerKeyCommandWithInput:(NSString *)input
                      modifierFlags:(UIKeyModifierFlags)flags
                             action:(void (^)(UIKeyCommand *command))block;

@end
