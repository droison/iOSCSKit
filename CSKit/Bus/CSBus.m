//
//  CSBus.m
//  CSKit
//
//  Created by song on 16/9/19.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "CSBus.h"
#import "CSEventProxy.h"
#import <objc/runtime.h>
#import "CSBusMethodFinder.h"

#warning todo 多线程调用的数据同步，selector定制的多线程

@implementation CSBus {
    NSMutableDictionary<NSString*, CSEventProxy*>* _eventProxyByProtocol;
    
    NSMapTable<NSString*, NSMutableSet<CSBusListener*>*>* _producersByType;
    
    CSBusMethodFinder* _methodFinder;
}

- (void)onServiceInit {
    _eventProxyByProtocol = [NSMutableDictionary new];
    _producersByType = [NSMapTable strongToStrongObjectsMapTable];
    _methodFinder = [[CSBusMethodFinder alloc] init];
}

- (BOOL)registerObserver:(NSObject*)obj protocol:(CSEventKey)oKey {
    if (obj == nil || oKey == nil) {
        NSLog(@"CSBus -- register observer[%@] for key[%@]", obj, oKey);
        assert(0);
        return NO;
    }
    
    if (![obj conformsToProtocol:oKey]) {
        NSLog(@"CSBus -- conformsToProtocol(%@, %@) is no", obj, oKey);
        assert(0);
        return NO;
    }
    
    NSString *key = NSStringFromProtocol(oKey);
    
    CSEventProxy* proxy = [_eventProxyByProtocol objectForKey:key];
    
    if (proxy == nil) {
        proxy = [[CSEventProxy alloc] initWithReceivers:nil methodFinder:_methodFinder];
        [_eventProxyByProtocol setObject:proxy forKey:key];
    }
    
    [proxy addReceiver:obj];
    
    NSMutableSet<CSBusListener*>* listeners = [_producersByType objectForKey:key];
    for (CSBusListener* listener in listeners) {
        [listener onRegisterListener:obj];
    }
    
    return YES;
}

- (BOOL)unRegisterObserver:(NSObject*)obj protocol:(CSEventKey)oKey{
    if (obj == nil || oKey == nil) {
        NSLog(@"CSBus -- register observer[%@] for key[%@]", obj, oKey);
        assert(0);
        return NO;
    }
    
    if (![obj conformsToProtocol:oKey]) {
        NSLog(@"CSBus -- conformsToProtocol(%@, %@) is no", obj, oKey);
        assert(0);
        return NO;
    }
    
    NSString *key = NSStringFromProtocol(oKey);
    
    CSEventProxy* proxy = [_eventProxyByProtocol objectForKey:key];
    
    if (proxy != nil) {
        if ([proxy removeReceiver:obj] && [proxy getTargetReceiverCount] == 0) {
            [_eventProxyByProtocol removeObjectForKey:key];
        };
    }
    
    return YES;
}

- (BOOL)unRegisterObserver:(NSObject *)observer{
    if (observer == nil) {
        NSLog(@"CSBus -- unRegisterObserver observer[%@] is nil", observer);
        assert(0);
        return NO;
    }
    
    [_eventProxyByProtocol enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, CSEventProxy*  _Nonnull proxy, BOOL * _Nonnull stop) {
        CSEventKey eventkey = NSProtocolFromString(key);
        if ([observer conformsToProtocol:eventkey]) {
            if ([proxy removeReceiver:observer] && [proxy getTargetReceiverCount] == 0) {
                [_eventProxyByProtocol removeObjectForKey:key];
            }
        }
    }];
    
    return YES;
}



- (void)addRegisterListener:(NSObject *)observer{
    //OnSubscribe遍历,将其封装成Producer存到producersByType中
    NSDictionary<NSString*, CSBusListener*>* foundProducerMap = [_methodFinder getBusListener:observer];
    [foundProducerMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull type, CSBusListener * _Nonnull producer, BOOL * _Nonnull stop) {
        NSMutableSet<CSBusListener*>* producers = [_producersByType objectForKey:type];
        if (producers == nil) {
            //concurrent put if absent
            producers = [NSMutableSet set];
            [_producersByType setObject:producers forKey:type];
        }
        [producers addObject:producer];
    }];
}

- (void)removeRegisterListener:(NSObject *)observer {
    NSDictionary<NSString*, CSBusListener*>* foundProducerMap = [_methodFinder getBusListener:observer];
    [foundProducerMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull type, CSBusListener * _Nonnull producer, BOOL * _Nonnull stop) {
        NSMutableSet<CSBusListener*>* currentProducers = [_producersByType objectForKey:type];
        BOOL exist = NO;
        for (CSBusListener* currentProducer in currentProducers) {
            if ([currentProducer isEqual:producer]) {
                [currentProducer invalidate];
                exist = YES;
                break;
            }
        }
        if (exist) {
            [currentProducers removeObject:producer];
        } else {
            NSLog(@"CSBus -- error: producer[%@] is not exist", producer);
        }
    }];
}

- (id)getReceiver:(CSEventKey)oKey{
    if (oKey == nil) {
        NSLog(@"CSBus -- getReceiver for key[%@] is nil", oKey);
        assert(0);
        return nil;
    }
    
    CSEventProxy *proxy = [_eventProxyByProtocol objectForKey:NSStringFromProtocol(oKey)];
    return proxy;
}

@end
