//
//  QDBusListener.h
//  QDKit
//
//  Created by song on 2016/9/28.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QDKitMacro.h"

typedef enum : NSInteger {
    QDBusThreadMain = 0,
    QDBusThreadCurrent
} QDBusThread;

@interface QDBusMethod : NSObject
@property(nonatomic, assign, readonly) Class cls;
@property(nonatomic, assign, readonly) SEL selector;
@property(nonatomic, copy, readonly) NSString* type;
@property(nonatomic, assign, readonly) QDBusThread thread;
- (instancetype)initWithClass:(Class)cls sel:(SEL)selector type:(NSString*)type thread:(QDBusThread)thread;
@end

@interface QDBusListener : NSObject

@property(nonatomic, strong, readonly) id targetObj;
@property(nonatomic, strong, readonly) QDBusMethod* method;

- (instancetype)initWithTarget:(id)target method:(QDBusMethod*)method;
- (void)onRegisterListener:(id)obj;

- (void)invalidate;
@end
