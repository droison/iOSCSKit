//
//  QDEventProxy.h
//  QDKit
//
//  Created by song on 16/9/19.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QDKitMacro.h"

@class QDBusMethodFinder;

@interface QDEventProxy : NSProxy
- (instancetype)initWithReceivers:(NSSet *)_receivers methodFinder:(QDBusMethodFinder*) methodFinder;

- (BOOL)addReceiver:(id)receicer;
- (BOOL)removeReceiver:(id)receicer;

- (int)getTargetReceiverCount;

- (void)invalidate;
@end
