//
//  CSMacro.h
//  droison
//
//  Created by song on 16/11/28.
//  Copyright © 2016年 droison. All rights reserved.
//

#if defined(__cplusplus)
#define CS_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define CS_EXTERN extern __attribute__((visibility("default")))
#endif

#define q_dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define q_dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
