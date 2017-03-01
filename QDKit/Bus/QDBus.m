//
//  QDBus.m
//  QDKit
//
//  Created by song on 16/9/19.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDBus.h"
#import "QDEventProxy.h"
#import <objc/runtime.h>
#import "QDBusMethodFinder.h"

@implementation QDBus {
    NSMutableDictionary<NSString*, QDEventProxy*>* _eventProxyByProtocol;
    
    NSMapTable<NSString*, NSMutableSet<QDBusListener*>*>* _producersByType;
    
    QDBusMethodFinder* _methodFinder;
}

- (void)onServiceInit {
    _eventProxyByProtocol = [NSMutableDictionary new];
    _producersByType = [NSMapTable strongToStrongObjectsMapTable];
    _methodFinder = [[QDBusMethodFinder alloc] init];
}

- (BOOL)registerObserver:(NSObject*)obj protocol:(QDEventKey)oKey {
    if (obj == nil || oKey == nil) {
        CSLog(@"QDBus -- register observer[%@] for key[%@]", obj, oKey);
        assert(0);
        return NO;
    }
    
    if (![obj conformsToProtocol:oKey]) {
        CSLog(@"QDBus -- conformsToProtocol(%@, %@) is no", obj, oKey);
        assert(0);
        return NO;
    }
    
    NSString *key = NSStringFromProtocol(oKey);
    
    QDEventProxy* proxy = [_eventProxyByProtocol objectForKey:key];
    
    if (proxy == nil) {
        proxy = [[QDEventProxy alloc] initWithReceivers:nil methodFinder:_methodFinder];
        [_eventProxyByProtocol setObject:proxy forKey:key];
    }
    
    [proxy addReceiver:obj];
    
    NSMutableSet<QDBusListener*>* listeners = [_producersByType objectForKey:key];
    for (QDBusListener* listener in listeners) {
        [listener onRegisterListener:obj];
    }
    
    return YES;
}

- (BOOL)unRegisterObserver:(NSObject*)obj protocol:(QDEventKey)oKey{
    if (obj == nil || oKey == nil) {
        CSLog(@"QDBus -- register observer[%@] for key[%@]", obj, oKey);
        assert(0);
        return NO;
    }
    
    if (![obj conformsToProtocol:oKey]) {
        CSLog(@"QDBus -- conformsToProtocol(%@, %@) is no", obj, oKey);
        assert(0);
        return NO;
    }
    
    NSString *key = NSStringFromProtocol(oKey);
    
    QDEventProxy* proxy = [_eventProxyByProtocol objectForKey:key];
    
    if (proxy != nil) {
        if ([proxy removeReceiver:obj] && [proxy getTargetReceiverCount] == 0) {
            [_eventProxyByProtocol removeObjectForKey:key];
        };
    }
    
    return YES;
}

- (BOOL)unRegisterObserver:(NSObject *)observer{
    if (observer == nil) {
        CSLog(@"QDBus -- unRegisterObserver observer[%@] is nil", observer);
        assert(0);
        return NO;
    }
    
    [_eventProxyByProtocol enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, QDEventProxy*  _Nonnull proxy, BOOL * _Nonnull stop) {
        QDEventKey eventkey = NSProtocolFromString(key);
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
    NSDictionary<NSString*, QDBusListener*>* foundProducerMap = [_methodFinder getBusListener:observer];
    [foundProducerMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull type, QDBusListener * _Nonnull producer, BOOL * _Nonnull stop) {
        NSMutableSet<QDBusListener*>* producers = [_producersByType objectForKey:type];
        if (producers == nil) {
            //concurrent put if absent
            producers = [NSMutableSet set];
            [_producersByType setObject:producers forKey:type];
        }
        [producers addObject:producer];
    }];
}

- (void)removeRegisterListener:(NSObject *)observer {
    NSDictionary<NSString*, QDBusListener*>* foundProducerMap = [_methodFinder getBusListener:observer];
    [foundProducerMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull type, QDBusListener * _Nonnull producer, BOOL * _Nonnull stop) {
        NSMutableSet<QDBusListener*>* currentProducers = [_producersByType objectForKey:type];
        BOOL exist = NO;
        for (QDBusListener* currentProducer in currentProducers) {
            if ([currentProducer isEqual:producer]) {
                [currentProducer invalidate];
                exist = YES;
                break;
            }
        }
        if (exist) {
            [currentProducers removeObject:producer];
        } else {
            CSLog(@"QDBus -- error: producer[%@] is not exist", producer);
        }
    }];
}

- (id)getReceiver:(QDEventKey)oKey{
    if (oKey == nil) {
        CSLog(@"QDBus -- getReceiver for key[%@] is nil", oKey);
        assert(0);
        return nil;
    }
    
    QDEventProxy *proxy = [_eventProxyByProtocol objectForKey:NSStringFromProtocol(oKey)];
    return proxy;
}

@end
