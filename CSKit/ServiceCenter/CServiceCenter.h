//
//  CServiceCenter.h
//  CSKit
//
//  Created by song on 14/11/12.
//  Copyright (c) 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSKitMacro.h"

@interface CService : NSObject {
    BOOL m_isServiceRemoved;
    BOOL m_isServiceUnPersistent;		// 注销或者退出时, 是否还需要清掉，默认不清掉
}

#define CS_REGISTER() \
CS_EXTERN void CSRegisterInit(Class); \
+ (void)load { CSRegisterInit(self); }

@property (assign) BOOL m_isServiceRemoved;
@property (assign) BOOL m_isServiceUnPersistent;

@end

/// MMService协议
@protocol CService<NSObject>

@optional

// call after yourservice create.
-(void) onServiceInit;

// 进入后台运行
-(void) onServiceEnterBackground;

// 进入前台运行
-(void) onServiceEnterForeground;

// memory fuck.
-(void) onServiceMemoryWarning;

// service被关闭时调用
-(void) onServiceTerminate;

/**
 * 下面都是一些与账号有关的操作
 **/
// 切换帐号后， 调用。可能要重新加载数据到缓存
-(void) onServiceReloadData;

// 退出登录时调用 用于清理资源.
-(void) onServiceClearData;

@end

// 持久对象中心。 用来存放为全局服务的对象。
@interface CServiceCenter : NSObject

 // 由app管理本类的生命周期;
+(CServiceCenter *) defaultCenter;

// 获取服务对象。
// 如果对象不存在， 会自动创建。 但只能创建继承于MMService基类的对象.
- (id) getService:(Class) cls;

// 从core中移除， 但如果引用计数>1。。。凉拌吧。
-(void) removeService:(Class) cls;

// event
-(void) callEnterForeground;
-(void) callEnterBackground;
-(void) callServiceMemoryWarning;
-(void) callTerminate;
/**
 * 下面都是一些与账号有关的操作
 **/
-(void) callClearData;
-(void) callReloadData;

@end

#define GET_SERVICE(obj) ((obj*)[[CServiceCenter defaultCenter] getService:[obj class]])

#define REMOVE_SERVICE(obj) [[CServiceCenter defaultCenter] removeService:[obj class]]
