//
//  QDServiceCenter.h
//  QDKit
//
//  Created by song on 14/11/12.
//  Copyright (c) 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QDKitMacro.h"

#define QDService_REGISTER() \
QD_EXTERN void CSRegisterInit(Class); \
+ (void)load { CSRegisterInit(self); }

@interface QDService : NSObject {
    BOOL m_isServiceRemoved;
    BOOL m_isServiceUnPersistent;		// 注销或者退出时, 是否还需要清掉，默认不清掉
}

@property (nonatomic, assign) BOOL m_isServiceRemoved;
@property (nonatomic, assign) BOOL m_isServiceUnPersistent;
@property (nonatomic, assign) uint16_t level; //default为0 越高优先级越高

@end

/// QDService协议
@protocol QDService<NSObject>

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
@interface QDServiceCenter : NSObject

 // 由app管理本类的生命周期;
+(QDServiceCenter *) defaultCenter;

// 获取服务对象。
// 如果对象不存在， 会自动创建。 但只能创建继承于QDService基类的对象.
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

#define GET_SERVICE(obj) ((obj*)[[QDServiceCenter defaultCenter] getService:[obj class]])

#define REMOVE_SERVICE(obj) [[QDServiceCenter defaultCenter] removeService:[obj class]]
