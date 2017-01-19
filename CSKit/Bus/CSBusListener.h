//
//  CSBusListener.h
//  droison
//
//  Created by song on 2016/9/28.
//  Copyright © 2016年 droison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSKitMacro.h"

typedef enum : NSInteger {
    CSBusThreadMain = 0,
    CSBusThreadCurrent
} CSBusThread;

@interface CSBusMethod : NSObject
@property(nonatomic, assign, readonly) Class cls;
@property(nonatomic, assign, readonly) SEL selector;
@property(nonatomic, copy, readonly) NSString* type;
@property(nonatomic, assign, readonly) CSBusThread thread;
- (instancetype)initWithClass:(Class)cls sel:(SEL)selector type:(NSString*)type thread:(CSBusThread)thread;
@end

@interface CSBusListener : NSObject

@property(nonatomic, strong, readonly) id targetObj;
@property(nonatomic, strong, readonly) CSBusMethod* method;

- (instancetype)initWithTarget:(id)target method:(CSBusMethod*)method;
- (void)onRegisterListener:(id)obj;

- (void)invalidate;
@end
