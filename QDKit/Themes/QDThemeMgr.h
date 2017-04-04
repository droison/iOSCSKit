//
//  QDThemeMgr.h
//  JSONTHEMETest
//
//  Created by song on 14-10-17.
//  Copyright (c) 2014年 droison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QDKitMacro.h"

typedef NSArray<NSString*> *(^QDThemeMgrSourcePathsBlock)();

typedef NSString *(^QDThemeMgrConstantSourcePathBlock)();

QD_EXTERN void QDThemeMgrDefaultConfig();

@interface QDThemeMgr : NSObject {
    NSMutableDictionary* _imageCache;
    NSInteger m_cachedImageSize;
}

@property (nonatomic, strong) NSMutableDictionary *imageCache;
@property(nonatomic, copy) QDThemeMgrSourcePathsBlock resourcePathsBlock;
@property(nonatomic, copy) QDThemeMgrConstantSourcePathBlock constantPathBlock;

+ (QDThemeMgr*)sharedThemeManager;

- (void) reloadBasedHost:(NSString*) host complete:(void(^)())complete;

//以下三个方法会在模拟器加锁，避免请求网络。
- (void) prepare; //请配置好block后手动调用prepare方法
- (NSArray*)getValueOfProperty:(NSString*)property forSeletor:(NSString *)selector;
- (NSArray*) constantsValueForKey:(NSString*) key;

- (UIImage *)imageNamed:(NSString *)imgName;

- (UIImage *)imageFromColor:(UIColor *)oColor;

+ (UIImage*) hdImageWithContentsOfFile:(NSString *)path;
+ (BOOL) isFileExist:(NSString *)fileName;

- (void) cacheImage:(UIImage*)imageData forKey:(NSString*)url;
- (void) clearImageCache;
/**
 *  可以根据后台传入的数据，动态修改某一个css主题下面的某个固定的selector下的资源
 *
 *  @param theme    css文件名称 iPhone下包含：default、nightmode两种 iPad下有iPad2Column、iPad3Column、iPad4Column三种
 *  @param selector selector名称
 *  @param dataDic  要修改的selector下的数据
 */
- (void) updateTheme:(NSString*) theme selector:(NSString*) selector content:(NSDictionary*) dataDic;
@end

#define THEME_MGR [QDThemeMgr sharedThemeManager]
