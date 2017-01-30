//
//  CSKitMacro.h
//  CSKit
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
