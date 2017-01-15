//
//  CSEventProxy.h
//  droison
//
//  Created by song on 16/9/19.
//  Copyright © 2016年 droison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSMacro.h"

@class CSBusMethodFinder;

@interface CSEventProxy : NSProxy
- (instancetype)initWithReceivers:(NSSet *)_receivers methodFinder:(CSBusMethodFinder*) methodFinder;

- (BOOL)addReceiver:(id)receicer;
- (BOOL)removeReceiver:(id)receicer;

- (int)getTargetReceiverCount;

- (void)invalidate;
@end
