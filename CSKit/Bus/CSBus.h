//
//  CSBus.h
//  CSKit
//
//  Created by song on 16/9/19.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CServiceCenter.h"

typedef Protocol * CSEventKey;


@protocol CSBusProtocol <NSObject>

- (BOOL)registerObserver:(NSObject*)obj protocol:(CSEventKey)oKey ;
- (BOOL)unRegisterObserver:(NSObject*)obj protocol:(CSEventKey)oKey ;

- (BOOL)unRegisterObserver:(NSObject*)obj;

//默认所有请求都发送到主线程，如果想改为当前post线程，请该方法用 宏 'BUS_POSTTHREAD_METHOD'包上
- (id) getReceiver:(CSEventKey)oKey;

//请所有Listenter方法都使用 'BUS_LISTENER_METHOD'宏包上
//在当前线程调用，如果想在主线程处理，请使用 'BUS_LISTENER_MAIN_METHOD' 宏包上
- (void)addRegisterListener:(NSObject *)observer;
- (void)removeRegisterListener:(NSObject *)observer;

@end


@interface CSBus : CService<CService, CSBusProtocol>

@end

#define DEFAULT_BUS GET_SERVICE(CSBus)

#define BUS_CONCAT2(A, B) A ## B
#define BUS_CONCAT(A, B) BUS_CONCAT2(A, B)

#define BUS_THREAD_METHOD(thread_name, method) \
BUS_EXTERN_REMAP_METHOD(thread_name, method) \
- (void)method


#define BUS_EXTERN_REMAP_METHOD(thread_name, method) \
+ (NSArray<NSString *> *)BUS_CONCAT(__busthread_export__, \
BUS_CONCAT(thread_name, BUS_CONCAT(__LINE__, __COUNTER__))) { \
return @[@#thread_name, @#method]; \
}


#define BUS_LISTENER_THREAD_METHOD(thread_name, method) \
BUS_LISTENER_EXTERN_REMAP_METHOD(thread_name, method) \
- (void)method

#define BUS_LISTENER_EXTERN_REMAP_METHOD(thread_name, method) \
+ (NSArray<NSString *> *)BUS_CONCAT(__bus_listener_thread_export__, \
BUS_CONCAT(thread_name, BUS_CONCAT(__LINE__, __COUNTER__))) { \
return @[@#thread_name, @#method]; \
}



//所有外部业务可用宏都在下面列出
#define REGISTER_OBSERVER(oKey, obj)	[DEFAULT_BUS registerObserver:obj protocol:@protocol(oKey)]

#define UNREGISTER_OBSERVER(oKey, obj)	[DEFAULT_BUS unRegisterObserver:obj protocol:@protocol(oKey)]

#define UNREGISTER_ALL_OBSERVER(obj)	[DEFAULT_BUS unRegisterObserver:obj]

#define GET_RECEIVER(oKey) ((id<oKey>) [DEFAULT_BUS getReceiver:@protocol(oKey)])

#define POST_EVENT(oKey, func)	\
{\
id<oKey> __receiver__ = GET_RECEIVER(oKey); \
if (__receiver__)  [__receiver__ func]; \
}

#define SAFEPOST_EVENT(oKey, func) \
{ \
cs_dispatch_main_async_safe(^{ \
POST_EVENT(oKey, func); \
}); \
}

//以下3个为方法修饰宏
#define BUS_POSTTHREAD_METHOD(method) \
BUS_THREAD_METHOD(current, method)

#define BUS_LISTENER_METHOD(method) \
BUS_LISTENER_THREAD_METHOD(current, method)

#define BUS_LISTENER_MAIN_METHOD(method) \
BUS_LISTENER_THREAD_METHOD(main, method)
