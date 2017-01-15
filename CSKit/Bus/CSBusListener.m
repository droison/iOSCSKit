//
//  CSBusListener.m
//  droison
//
//  Created by song on 2016/9/28.
//  Copyright © 2016年 droison. All rights reserved.
//

#import "CSBusListener.h"

@implementation CSBusMethod

- (instancetype)initWithClass:(Class)cls sel:(SEL)selector type:(NSString *)type thread:(CSBusThread)thread {
    if (self = [super init]) {
        _cls = cls;
        _selector = selector;
        _type = type;
        _thread = thread;
    }
    return self;
}

- (NSUInteger)hash {
    return _cls.hash ^ [NSStringFromSelector(_selector) hash] ^ _type.hash;
}

@end

@implementation CSBusListener {
    NSUInteger _hashCode;
    BOOL _valid;
}

- (instancetype)initWithTarget:(id)target method:(CSBusMethod *)method{
    if (self = [super init]) {
        _targetObj = target;
        _method = method;
        _hashCode = [target hash]^ method.hash;
        _valid = YES;
    }
    return self;
}

- (void)onRegisterListener:(id)obj {
    if (!_valid) {
        return;
    }
    
    if (![obj conformsToProtocol:NSProtocolFromString(_method.type)]) { //判断obj实现了_method.type协议
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

    if ([_targetObj respondsToSelector:_method.selector]) {
        if (_method.thread == CSBusThreadMain) {
            q_dispatch_main_sync_safe(^(){
                if (_valid) {
                    [_targetObj performSelector:_method.selector withObject:obj];
                }
            })
        } else {
            [_targetObj performSelector:_method.selector withObject:obj];
        }
    }
    
#pragma clang diagnostic pop
}

- (void)invalidate {
    _valid = NO;
}

- (NSUInteger)hash {
    if (_hashCode == 0) {
        _hashCode = [super hash];
    }
    return _hashCode;
}

- (BOOL)isEqual:(CSBusListener *)object {
    if (self == object) return YES;
    if (![object isMemberOfClass:[self class]]) return NO;
    
    return object.hash == _hashCode;
}

@end
