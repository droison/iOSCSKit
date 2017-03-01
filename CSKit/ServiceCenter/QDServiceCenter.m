//
//  QDServiceCenter.m
//  CSKit
//
//  Created by song on 14/11/12.
//  Copyright (c) 2017年 Personal. All rights reserved.
//

#import "QDServiceCenter.h"

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


@implementation QDService
@synthesize m_isServiceRemoved;
@synthesize m_isServiceUnPersistent;

-(void)dealloc
{
}

@end

@implementation QDServiceCenter {
    NSMutableDictionary *_diQDService;
}

- (instancetype) init
{
    if(self = [super init])
    {
        CSLog(@"QDServiceCenter -- Create service center");
        _diQDService = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc
{
    if(_diQDService != nil)
    {
        CSLog(@"QDServiceCenter -- dealloc service center");
        _diQDService = nil;
    }
}
static QDServiceCenter* g_ServiceCenter;

+(QDServiceCenter *) defaultCenter
{
    // 由app管理本类的生命周期; 此处不实用dispatch_once的原因在于希望强制主线程初始化
    if (g_ServiceCenter == nil) { //初次判断，提高效率
        qd_dispatch_main_sync_safe(^{
            if (g_ServiceCenter == nil) { // 二次判断，在相同线程，避免出问题
                g_ServiceCenter = [[QDServiceCenter alloc] init];
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
    NSAssert([cls conformsToProtocol:@protocol(QDService)], @"%@ does not conform to the QDService protocol", cls);
    NSAssert([cls isSubclassOfClass:[QDService class]], @"%@ is not a QDService", cls);

    __block id obj = [_diQDService objectForKey:[cls description]];
    if (obj == nil)
    {
        qd_dispatch_main_sync_safe(^{
            obj = [[cls alloc] init];
            [_diQDService setObject:obj forKey:[cls description]];
            
            CSLog(@"QDServiceCenter -- Create service object: %@", obj);
            
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
    qd_dispatch_main_async_safe(^{
        QDService<QDService>* obj = [_diQDService objectForKey:[cls description]];
        if (obj == nil)
        {
            return ;
        }
        if ([obj respondsToSelector:@selector(onServiceTerminate)])
        {
            [obj onServiceTerminate];
        }
        [_diQDService removeObjectForKey:[cls description]];
        obj.m_isServiceRemoved = YES;
        obj = nil;
    });
}

-(void) callEnterForeground
{
    qd_dispatch_main_async_safe(^{
        NSArray *aryCopy = [_diQDService allValues];
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
    qd_dispatch_main_async_safe(^{
        NSArray *aryCopy = [_diQDService allValues];
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
    qd_dispatch_main_async_safe(^{
        NSArray *aryCopy = [_diQDService allValues];
        for(id obj in aryCopy)
        {
            if ([obj respondsToSelector:@selector(onServiceTerminate)])
            {
                [obj onServiceTerminate];
            }
        }
        [_diQDService removeAllObjects];
    });
}

-(void) callServiceMemoryWarning
{
    qd_dispatch_main_async_safe(^{
        NSArray *aryCopy = [_diQDService allValues];
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
    qd_dispatch_main_async_safe(^{
        NSArray *aryCopy = [_diQDService allValues];
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
    qd_dispatch_main_async_safe(^{
        NSArray *aryCopy = [_diQDService allValues];
        
        for(QDService<QDService>* obj in aryCopy)
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
