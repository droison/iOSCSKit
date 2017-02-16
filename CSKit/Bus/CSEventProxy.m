//
//  CSEventProxy.m
//  CSKit
//
//  Created by song on 16/9/19.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "CSEventProxy.h"
#import "CSBusMethodFinder.h"

@interface CSEventDefaultReceiver : NSObject
- (id)__magicSelector:(id)a b:(id)b c:(id)c d:(id)d e:(id)e f:(id)f g:(id)g h:(id)h i:(id)i j:(id)j k:(id)k l:(id)l m:(id)m;
@end

@implementation CSEventDefaultReceiver

- (id)__magicSelector:(id)a b:(id)b c:(id)c d:(id)d e:(id)e f:(id)f g:(id)g h:(id)h i:(id)i j:(id)j k:(id)k l:(id)l m:(id)m {
    return nil;
}

@end

@implementation CSEventProxy {
    NSHashTable* _receivers;;
    CSBusMethodFinder* _methodFinder;
    BOOL _valid;
}

- (instancetype ) initWithReceivers:(NSSet *)receivers methodFinder:(CSBusMethodFinder*) methodFinder{
    _receivers = [NSHashTable weakObjectsHashTable];
    for (id receiver in receivers) {
        [_receivers addObject:receiver];
    }
    _methodFinder = methodFinder;
    _valid = YES;
    return self;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    // 获取 selector 的名字（如前面的 loginWithId:password:）
    NSHashTable* currentReceiver = [_receivers copy];
    for (id obj in currentReceiver) {
        if ([obj respondsToSelector:anInvocation.selector]) {
            if ([self needMainThread:obj selector:anInvocation.selector]) {
                cs_dispatch_main_sync_safe(^{ //同步调用
                    [anInvocation setTarget:obj];
                    [anInvocation invoke];
                });
            } else {
                [anInvocation setTarget:obj];
                [anInvocation invoke];
            }
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    if (_receivers.count) {
        return [_receivers.anyObject methodSignatureForSelector:selector];
    }
    
    static dispatch_once_t once;
    static NSMethodSignature* ms = nil;
    dispatch_once(&once, ^{
        ms = [[[CSEventDefaultReceiver alloc]init] methodSignatureForSelector:@selector(__magicSelector:b:c:d:e:f:g:h:i:j:k:l:m:)];
    });
    return ms;
}

- (BOOL)addReceiver:(id)receicer {
    if (![_receivers containsObject:receicer]) {
        [_receivers addObject:receicer];
        return YES;
    }
    return NO;
}

- (BOOL)removeReceiver:(id)receicer {
    if ([_receivers containsObject:receicer]) {
        [_receivers removeObject:receicer];
        return YES;
    }
    return NO;
}

- (int)getTargetReceiverCount {
    return (int)_receivers.count;
}

- (void)invalidate {
    _valid = NO;
}

- (BOOL)needMainThread:(id)obj selector:(SEL)sel {
    NSSet<NSString*> *postThreadMethod = [_methodFinder getPostThread:obj];
    return ![postThreadMethod containsObject:NSStringFromSelector(sel)];
}

@end
