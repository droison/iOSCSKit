//
//  CSKitMacro.h
//  CSKitDemo
//
//  Created by song on 2017/1/19.
//  Copyright © 2017年 Personal. All rights reserved.
//

#define CSEmptyString(str) ([str isKindOfClass:[NSNull class]] || str == nil || str.length == 0)
#if defined(__cplusplus)
#define CS_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define CS_EXTERN extern __attribute__((visibility("default")))
#endif

#define cs_dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define cs_dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


#ifdef DEBUG

#define CSLogV(format, ...) NSLog((@"-[V]:%d %s " format), __LINE__,__PRETTY_FUNCTION__, ##__VA_ARGS__); \
NSLog((@"✍💜[V]:%d %s " format), __LINE__,__PRETTY_FUNCTION__, ##__VA_ARGS__);

#define CSLogD(format, ...) NSLog((@"-[D]:%d %s " format), __LINE__,__PRETTY_FUNCTION__, ##__VA_ARGS__); \
NSLog((@"✍💚[D]:%d %s " format), __LINE__,__PRETTY_FUNCTION__, ##__VA_ARGS__);

#define CSLogI(format, ...) NSLog((@"-[I]:%d %s " format), __LINE__,__PRETTY_FUNCTION__, ##__VA_ARGS__); \
NSLog((@"✍💙[I]:%d %s " format), __LINE__,__PRETTY_FUNCTION__, ##__VA_ARGS__);

#define CSLogW(format, ...) NSLog((@"-[W]:%d %s " format), __LINE__,__PRETTY_FUNCTION__, ##__VA_ARGS__); \
NSLog((@"✍💛[W]:%d %s " format), __LINE__,__PRETTY_FUNCTION__, ##__VA_ARGS__);

#define CSLogE(format, ...) NSLog((@"-[E]:%d %s " format), __LINE__,__PRETTY_FUNCTION__, ##__VA_ARGS__); \
NSLog((@"✍❤️[E]:%d %s " format), __LINE__,__PRETTY_FUNCTION__, ##__VA_ARGS__);

#else

#define LogV(format, ...)
#define LogD(format, ...)
#define LogI(format, ...) NSLog((@"-[I]:%d %s " format), __LINE__,__PRETTY_FUNCTION__, ##__VA_ARGS__);
#define LogW(format, ...) NSLog((@"-[W]:%d %s " format), __LINE__,__PRETTY_FUNCTION__, ##__VA_ARGS__);
#define LogE(format, ...) NSLog((@"-[E]:%d %s " format), __LINE__,__PRETTY_FUNCTION__, ##__VA_ARGS__);

#endif

