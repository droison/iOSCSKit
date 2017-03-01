//
//  QDKitMacro.h
//  QDKit
//
//  Created by song on 2017/1/19.
//  Copyright © 2017年 Personal. All rights reserved.
//

#define CSDebug YES

#ifdef CSDebug
#define CSLog(format, ...) NSLog((@"[CSLog]:%d %s " format), __LINE__,__PRETTY_FUNCTION__, ##__VA_ARGS__);
#else
#define CSLog(format, ...)
#endif

#define CSEmptyString(str) ([str isKindOfClass:[NSNull class]] || str == nil || str.length == 0)
#if defined(__cplusplus)
#define QD_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define QD_EXTERN extern __attribute__((visibility("default")))
#endif

#define qd_dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define qd_dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
