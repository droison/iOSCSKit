//
//  CServiceCenter.m
//  CSKit
//
//  Created by song on 14/11/12.
//  Copyright (c) 2017年 Personal. All rights reserved.
//

#import "CServiceCenter.h"

static NSMutableArray<Class> *CSInitClasses;
NSArray<Class> *CSGetInitClasses(void);
NSArray<Class> *CSGetInitClasses(void)
{
    return CSInitClasses;
}

/**
 * Register the given class as a bridge module. All modules must be registered
 * prior to the first bridge initialization.
 */
void CSRegisterInit(Class);
void CSRegisterInit(Class moduleClass)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CSInitClasses = [NSMutableArray new];
    });
    // Register module
    [CSInitClasses addObject:moduleClass];
}


@implementation CService
@synthesize m_isServiceRemoved;
@synthesize m_isServiceUnPersistent;

-(void)dealloc
{
}

@end

@implementation CServiceCenter {
    NSMutableDictionary *_diCService;
}

- (instancetype) init
{
    if(self = [super init])
    {
        NSLog(@"CServiceCenter -- Create service center");
        _diCService = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc
{
    if(_diCService != nil)
    {
        NSLog(@"CServiceCenter -- dealloc service center");
        _diCService = nil;
    }
}
static CServiceCenter* g_ServiceCenter;

+(CServiceCenter *) defaultCenter
{
    // 由app管理本类的生命周期; 此处不实用dispatch_once的原因在于希望强制主线程初始化
    if (g_ServiceCenter == nil) { //初次判断，提高效率
        cs_dispatch_main_sync_safe(^{
            if (g_ServiceCenter == nil) { // 二次判断，在相同线程，避免出问题
                g_ServiceCenter = [[CServiceCenter alloc] init];
                for (Class moduleClass in CSGetInitClasses()) {
                    [g_ServiceCenter getService:moduleClass];
                }
            }
        });
    }
    return g_ServiceCenter;
}

-(id) getService:(Class) cls
{
    NSAssert([cls conformsToProtocol:@protocol(CService)], @"%@ does not conform to the CService protocol", cls);
    NSAssert([cls isSubclassOfClass:[CService class]], @"%@ is not a CService", cls);

    __block id obj = [_diCService objectForKey:[cls description]];
    if (obj == nil)
    {
        cs_dispatch_main_sync_safe(^{
            obj = [[cls alloc] init];
            [_diCService setObject:obj forKey:[cls description]];
            
            NSLog(@"CServiceCenter -- Create service object: %@", obj);
            
            // call init
            if ([obj respondsToSelector:@selector(onServiceInit)])
            {
                [obj onServiceInit];
            }
        });
    }
    
    
    return obj;
}

-(void) removeService:(Class) cls
{
    cs_dispatch_main_async_safe(^{
        CService<CService>* obj = [_diCService objectForKey:[cls description]];
        if (obj == nil)
        {
            return ;
        }
        if ([obj respondsToSelector:@selector(onServiceTerminate)])
        {
            [obj onServiceTerminate];
        }
        [_diCService removeObjectForKey:[cls description]];
        obj.m_isServiceRemoved = YES;
        obj = nil;
    });
}

-(void) callEnterForeground
{
    cs_dispatch_main_async_safe(^{
        NSArray *aryCopy = [_diCService allValues];
        for(id obj in aryCopy)
        {
            if ([obj respondsToSelector:@selector(onServiceEnterForeground)])
            {
                [obj onServiceEnterForeground];
            }
        }
    });
}

-(void) callEnterBackground
{
    cs_dispatch_main_async_safe(^{
        NSArray *aryCopy = [_diCService allValues];
        for(id obj in aryCopy)
        {
            if ([obj respondsToSelector:@selector(onServiceEnterBackground)])
            {
                [obj onServiceEnterBackground];
            }
        }
    });
}

-(void) callTerminate
{
    cs_dispatch_main_async_safe(^{
        NSArray *aryCopy = [_diCService allValues];
        for(id obj in aryCopy)
        {
            if ([obj respondsToSelector:@selector(onServiceTerminate)])
            {
                [obj onServiceTerminate];
            }
        }
        [_diCService removeAllObjects];
    });
}

-(void) callServiceMemoryWarning
{
    cs_dispatch_main_async_safe(^{
        NSArray *aryCopy = [_diCService allValues];
        for(id obj in aryCopy)
        {
            if ([obj respondsToSelector:@selector(onServiceMemoryWarning)])
            {
                [obj onServiceMemoryWarning];
            }
        }
    });
}

-(void) callReloadData
{
    cs_dispatch_main_async_safe(^{
        NSArray *aryCopy = [_diCService allValues];
        for(id obj in aryCopy)
        {
            if ([obj respondsToSelector:@selector(onServiceReloadData)])
            {
                [obj onServiceReloadData];
            }
        }
    });
}

-(void) callClearData
{
    cs_dispatch_main_async_safe(^{
        NSArray *aryCopy = [_diCService allValues];
        
        for(CService<CService>* obj in aryCopy)
        {
            if ([obj respondsToSelector:@selector(onServiceClearData)])
            {
                [obj onServiceClearData];
            }
            
            if (obj.m_isServiceUnPersistent == YES)
            {
                // remove
                [self removeService:[obj class]];
                // 注意：removeService后，obj不能再使用。fase enumeration 中，obj不会增加计数，当obj从数组移除后，obj可能会释放，不能再访问。
            }
            else
            {
                // keep
            }
        }
    });
}
@end
