//
//  QDThemeMgr.m
//  JSONTHEMETest
//
//  Created by song on 14-10-17.
//  Copyright (c) 2014年 droison. All rights reserved.
//

#import "QDThemeMgr.h"
#import "UIImage+QDColor.h"
#import "NICSSParser.h"
#import <AFNetWorking/AFHTTPSessionManager.h>
#import "QDDeviceInfo.h"
#import "QDKitMacro.h"
#import "QDUtils.h"

#if TARGET_OS_SIMULATOR //模拟器可能请求网络，做加锁处理。频繁加锁损害性能

#define ThemeLock() dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER)
#define ThemeUnlock() dispatch_semaphore_signal(self.lock)

#else

#define ThemeLock()
#define ThemeUnlock()

#endif

void QDThemeMgrDefaultConfig();
void QDThemeMgrDefaultConfig() {
    [QDThemeMgr sharedThemeManager].constantPathBlock = ^NSString *{
        NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
        return [bundleRoot stringByAppendingPathComponent:@"style~constants.css"];
        
    };
    
    [QDThemeMgr sharedThemeManager].resourcePathsBlock = ^NSArray<NSString *> *{
        NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
        NSString *path = [bundleRoot stringByAppendingPathComponent:@"style.css"];
        if ([QDDeviceInfo is320wScreen]) {
            NSString* iPhone5Path = [bundleRoot stringByAppendingPathComponent:@"style~iPhone5.css"];;
            return @[path, iPhone5Path];
        } else if ([QDDeviceInfo isiPhone6pScreen]) {
            NSString* iPhone6pPath = [bundleRoot stringByAppendingPathComponent:@"style~iPhone6p.css"];;
            return @[path, iPhone6pPath];
        } else {
            return @[path];
        }
    };
    
    [[QDThemeMgr sharedThemeManager] prepare];
}

@interface QDThemeMgr () {
    NSMutableDictionary* _resourceThemeDic;
    //上面这个iPhone使用
    NSMutableDictionary* _constantsThemeDic;
}

@property(nonatomic, strong) AFHTTPSessionManager* sessionManager;
@property(nonatomic, strong) dispatch_semaphore_t lock;
@end

@interface QDThemeMgr (iPhoneQDThemeMgr)
- (void) loadiPhoneCSSStyle;
- (NSArray*)getiPhoneValueOfProperty:(NSString*)property forSeletor:(NSString *)selector;
@end

@implementation QDThemeMgr {
}
#pragma mark - singleton
@synthesize imageCache = _imageCache;

static QDThemeMgr *sharedInstance_MMThemeManager = nil;

+ (void)initialize {
    if (sharedInstance_MMThemeManager == nil)
        sharedInstance_MMThemeManager = [[self alloc] init];
}

+ (QDThemeMgr *)sharedThemeManager {
    return sharedInstance_MMThemeManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    if (sharedInstance_MMThemeManager) {
        return sharedInstance_MMThemeManager;
    } else {
        return [super allocWithZone:zone];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        _resourceThemeDic = [[NSMutableDictionary alloc] init];
        _constantsThemeDic = [[NSMutableDictionary alloc] init];
        _imageCache = [[NSMutableDictionary alloc] init];
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)reloadBasedHost:(NSString *)host complete:(void (^)())complete{
#if TARGET_OS_SIMULATOR
    NSString* url = [host stringByAppendingPathComponent:@"config.json"];
    
    WeakSelf;
    
    NSString* (^convertUrl)(NSString*) = ^(NSString* obj) {
        if ([obj hasPrefix:@"http"]) {
            return obj;
        }
        return [host stringByAppendingPathComponent:obj];
    };
    
    NSArray* (^convertUrls)(NSArray*) = ^(NSArray* obj) {
        NSMutableArray* result = [NSMutableArray arrayWithCapacity:obj.count];
        for (NSString* url in obj) {
            [result addObject:convertUrl(url)];
        }
        return result;
    };
    
    [self.sessionManager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            StrongSelf;
            self.constantPathBlock = ^NSString *{
                return convertUrl([responseObject objectForKey:@"constant"]);
            };
            
            self.resourcePathsBlock = ^NSArray<NSString *> *{
                if ([QDDeviceInfo isiPad]) {
                    return convertUrls([responseObject objectForKey:@"ipad"]);
                }
                if ([QDDeviceInfo is320wScreen]) {
                    return convertUrls([responseObject objectForKey:@"iphone320"]);
                }
                if ([QDDeviceInfo isiPhone6pScreen]) {
                    return convertUrls([responseObject objectForKey:@"iphone414"]);
                }
                return convertUrls([responseObject objectForKey:@"iphone375"]);
            };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self prepare];
                if (complete) {
                    complete();
                }
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
#endif
}

- (void)prepare {
    [_resourceThemeDic removeAllObjects];
    [_constantsThemeDic removeAllObjects];
    [self loadConstantsCSSStyle];//要先load常量，resourc会直接覆盖常量，为了提高效率
    [self loadiPhoneCSSStyle];
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager == nil) {
        _sessionManager = [[AFHTTPSessionManager alloc] init];
        _sessionManager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    }
    return _sessionManager;
}

- (void)loadConstantsCSSStyle{
    if (_constantPathBlock) {
        NSString* contantsPath = _constantPathBlock();
        if ([contantsPath hasPrefix:@"http"]) {
            ThemeLock();
            WeakSelf;
            NSURLSessionDownloadTask* task = [self.sessionManager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:contantsPath]] progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                return [self cacheURLPath:targetPath];
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                StrongSelf;
                NSDictionary* parentDic = [[[NICSSParser alloc] init] dictionaryForPath:[filePath path]];
                [self rebuildConstantsDictionary:parentDic];
                ThemeUnlock();
            }];
            [task resume];
        } else {
            NSDictionary* parentDic = [[[NICSSParser alloc] init] dictionaryForPath:contantsPath];
            [self rebuildConstantsDictionary:parentDic];
        }
    }
}

-(void) rebuildConstantsDictionary:(NSDictionary*) dic {
    if (dic && [dic isKindOfClass:[NSDictionary class]] && dic.count > 0) {
        [dic enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL *stop) {
            if (![key isKindOfClass:[NSString class]] || obj == nil || ![obj isKindOfClass:[NSDictionary class]]) {
                return;
            }
            [obj enumerateKeysAndObjectsUsingBlock:^(NSString* childkey, id childValue, BOOL *stop) {
                if (![childkey isKindOfClass:[NSString class]] || childValue == nil || [childkey isEqualToString:kPropertyOrderKey]) {
                    return;
                }
                if ([childValue isKindOfClass:[NSArray class]]) {
                    [_constantsThemeDic setObject:childValue forKey:childkey];
                } else if ([childValue isKindOfClass:[NSString class]]) {
                    NSArray* childValueArray = [childValue componentsSeparatedByString:@" "];
                    if (childValueArray && childValueArray.count > 0) {
                        [_constantsThemeDic setObject:childValueArray forKey:childkey];
                    }
                }
            }];
        }];
    }
}

-(BOOL) rebuildThemeDictionary:(NSDictionary*)dic{
    if (dic == nil || dic.count == 0) {
        return NO;
    }
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL *stop) {
        if (![key isKindOfClass:[NSString class]] || obj == nil || ![obj isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        NSMutableDictionary* curChildDictionary = [_resourceThemeDic objectForKey:key];
        if (curChildDictionary == nil) {
            curChildDictionary = [NSMutableDictionary dictionary];
            [_resourceThemeDic setObject:curChildDictionary forKey:key];
        }
        
        __block NSMutableDictionary* blockCurChildDictionary = curChildDictionary;
        [obj enumerateKeysAndObjectsUsingBlock:^(NSString* childkey, id childValue, BOOL *stop) {
            if (![childkey isKindOfClass:[NSString class]] || childValue == nil || [childkey isEqualToString:kPropertyOrderKey]) {
                return;
            }
            if ([childValue isKindOfClass:[NSArray class]]) {
                [blockCurChildDictionary setObject:[self constantsValueForArray:childValue] forKey:childkey];
            } else if ([childValue isKindOfClass:[NSString class]]) {
                NSArray* childValueArray = [childValue componentsSeparatedByString:@" "];
                if (childValueArray && childValueArray.count > 0) {
                    [blockCurChildDictionary setObject:[self constantsValueForArray:childValueArray] forKey:childkey];
                }
            }
        }];
    }];
    
    return YES;
}

- (NSArray*)getValueOfProperty:(NSString*)property forSeletor:(NSString *)selector
{
    ThemeLock();
    NSArray* result = [self getiPhoneValueOfProperty:property forSeletor:selector];
    ThemeUnlock();
    return result;
}

- (NSArray* ) constantsValueForKey:(NSString*) key{
    if (CSEmptyString(key)) {
        return @[key];
    }
    ThemeLock();
    NSArray* result = [_constantsThemeDic objectForKey:key];
    ThemeUnlock();
    if (result) {
        return result;
    }
    return @[key];
}

- (NSArray* ) constantsValueForArray:(NSArray*) input{
    if (input == nil || input.count != 1) {
        return input;
    }
    NSArray* result = [_constantsThemeDic objectForKey:[input firstObject]];
    if (result) {
        return result;
    } else {
        return input;
    }
}

- (UIImage*)getImageCacheObjectForKey:(NSString *)theKey {
    return [[self imageCache] objectForKey:theKey];
}

- (UIImage *)imageFromColor:(UIColor *)oColor {
    if (oColor == nil) {
        return nil;
    }
    
    NSString *nsColorKey = oColor.description;
    if ([nsColorKey length] <= 0) {
        return nil;
    }
    
    UIImage *image = [self getImageCacheObjectForKey:nsColorKey];
    if (image != nil) {
        return image;
    }
    
    image = [[UIImage qd_imageWithColor:oColor] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    if ([self needToClearCache] == YES) {
        // clear cache
        [self clearImageCache];
    }
    [self setImageCacheObject:image forKey:nsColorKey];
    [self addImageSizeToCachedSize:image];
    
    return image;
}

- (UIImage *)imageNamed:(NSString *)imgName
{
    return [self privateImageNamed:imgName];
}

- (UIImage *)privateImageNamed:(NSString *)imgName
{
    UIImage *image = [self getImageCacheObjectForKey:imgName];
    if (image != nil) {
        return image;
    }
    
    
    if(image == nil){
        image = [self imageFromSystemFileContent:imgName];
    }
    
    // add to cache
    if (image != nil) {
        if ([self needToClearCache] == YES) {
            // clear cache
            [self clearImageCache];
            if (_imageCache == nil) {
                _imageCache = [NSMutableDictionary dictionary];
            }
        }
        [self setImageCacheObject:image forKey:imgName];
        [self addImageSizeToCachedSize:image];
    } else {
        
    }
    
    if (image == nil) {
        image = [UIImage imageNamed:imgName];
        if (image == nil) {
            CSLog(@"!!!!!!!!!!image not found[%@]", imgName);
        }
    }
    
    return image;
}

-(void) cacheImage:(UIImage*)imageData forKey:(NSString*)url
{
    if (imageData == nil) {
        return;
    }
    if ([self needToClearCache] == YES) {
        // clear cache
        [self clearImageCache];
        if (_imageCache == nil) {
            _imageCache = [NSMutableDictionary dictionary];
        }
    }
    [self setImageCacheObject:imageData forKey:url];
    [self addImageSizeToCachedSize:imageData];
}

- (BOOL) needToClearCache {
    static int s_maxCacehSize = -1;
    if (s_maxCacehSize <= 0) {
        s_maxCacehSize = [QDDeviceInfo screenWidth] * [QDDeviceInfo screenHeight] * 10;
    }
    if (m_cachedImageSize > s_maxCacehSize) {
        return YES;
    }
    return NO;
}

- (void)setImageCacheObject:(id)theImageCacheObject forKey:(NSString *)theKey {
    [_imageCache setObject:theImageCacheObject forKey:theKey];
}

- (void)addImageSizeToCachedSize:(UIImage *)image {
    m_cachedImageSize += (image.size.width * image.size.height);
}

-(UIImage*) imageFromSystemFileContent:(NSString *)imgName{
   
    NSString* ext = [imgName pathExtension];
    
    NSString* name = [imgName stringByDeletingPathExtension];
    
    NSString *imgNameiPad = [name stringByAppendingString:@"@iPad"];
    //如果是iPad先尝试iPad
    if ([QDDeviceInfo isiPad]){
        NSString* filepath = [[NSBundle mainBundle] pathForResource:imgNameiPad ofType:ext];
        if ([QDThemeMgr isFileExist:filepath]) {
            return [QDThemeMgr hdImageWithContentsOfFile:filepath];
        }
    }
    
    NSString *imgName1x = name;
    NSString *imgName2x = [name stringByAppendingString:@"@2x"];
    NSString *imgName3x = [name stringByAppendingString:@"@3x"];
    
    //先找3x的
    if ([QDDeviceInfo is3xScreen]){
        NSString* filepath = [[NSBundle mainBundle] pathForResource:imgName3x ofType:ext];
        if ([QDThemeMgr isFileExist:filepath]) {
            return [QDThemeMgr hdImageWithContentsOfFile:filepath];
        }
        
        //用2x的
        filepath = [[NSBundle mainBundle] pathForResource:imgName2x ofType:ext];
        if ([QDThemeMgr isFileExist:filepath]) {
            NSData * data = [NSData dataWithContentsOfFile:filepath];
            return [UIImage imageWithData:data scale:2.0];
        }
        
        //用1x的
        filepath = [[NSBundle mainBundle] pathForResource:imgName1x ofType:ext];
        if ([QDThemeMgr isFileExist:filepath]) {
            NSData * data = [NSData dataWithContentsOfFile:filepath];
            return [UIImage imageWithData:data];
        }
    }
    
    if ([QDDeviceInfo is2xScreen]) {
        NSString* filepath = [[NSBundle mainBundle] pathForResource:imgName2x ofType:ext];
        if ([QDThemeMgr isFileExist:filepath]) {
            return [QDThemeMgr hdImageWithContentsOfFile:filepath];
        }
        
        filepath = [[NSBundle mainBundle] pathForResource:imgName3x ofType:ext];
        if ([QDThemeMgr isFileExist:filepath]) {
            NSData * data = [NSData dataWithContentsOfFile:filepath];
            return [UIImage imageWithData:data scale:3.0];
        }
        
        filepath = [[NSBundle mainBundle] pathForResource:imgName1x ofType:ext];
        if ([QDThemeMgr isFileExist:filepath]) {
            NSData * data = [NSData dataWithContentsOfFile:filepath];
            return [UIImage imageWithData:data];
        }
        
    } else {
        NSString* filepath = [[NSBundle mainBundle] pathForResource:imgName1x ofType:ext];
        if ([QDThemeMgr isFileExist:filepath]) {
            NSData * data = [NSData dataWithContentsOfFile:filepath];
            return [UIImage imageWithData:data];
        }
        
        filepath = [[NSBundle mainBundle] pathForResource:imgName2x ofType:ext];
        if ([QDThemeMgr isFileExist:filepath]) {
            return [QDThemeMgr hdImageWithContentsOfFile:filepath];
        }
    }
    
    //如果上面两套逻辑都没有中，那就说明文件不存在或者程序传入的文件名不全，return nil，外层会在去做
    return nil;
}

- (void)clearImageCache {
    [_imageCache removeAllObjects];
}

+(UIImage*) hdImageWithContentsOfFile:(NSString *)path
{
    UIImage * oOriginImage = nil ;
    CGFloat fScale = [QDDeviceInfo screenScale];
    if( fScale <= 1.0f)
    {
        oOriginImage = [ UIImage imageWithContentsOfFile:path ] ;
        return oOriginImage ;
    }
    
    if( [self respondsToSelector:@selector(imageWithData:scale:)] )
    {
        oOriginImage = [ UIImage imageWithData:[NSData dataWithContentsOfFile:path] scale:fScale ] ;
    }else
    {
        oOriginImage = [ UIImage imageWithContentsOfFile:path ] ;
        oOriginImage = [ UIImage imageWithCGImage:oOriginImage.CGImage scale:fScale orientation:oOriginImage.imageOrientation ] ;
    }
    
    return oOriginImage ;
}

+ (BOOL) isFileExist:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:fileName];
    return result;
}

- (void) updateTheme:(NSString*) theme selector:(NSString*) selector content:(NSDictionary*) dataDic {
    if (CSEmptyString(selector) || dataDic == nil || dataDic.count == 0) {
        return;
    }
    
    NSMutableDictionary* targetDic = _resourceThemeDic[selector];
    if (targetDic == nil) {
        [_resourceThemeDic setObject:[NSMutableDictionary dictionaryWithDictionary:dataDic] forKey:selector];
    } else {
        for (NSString *key in dataDic) {
            [targetDic setObject:dataDic[key] forKey:key];
        }
    }
}

- (NSURL*) cacheURLPath:(NSURL*) url {
    NSString* cacheDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"qdtheme"];
    NSFileManager* defaultManager = [NSFileManager defaultManager];
    BOOL isDir;
    if ([defaultManager fileExistsAtPath:cacheDir isDirectory:&isDir]) {
        if (!isDir) {
            [defaultManager removeItemAtPath:cacheDir error:nil];
            [defaultManager createDirectoryAtPath:cacheDir withIntermediateDirectories:NO attributes:nil error:nil];
        }
    } else {
        [defaultManager createDirectoryAtPath:cacheDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString* tmpPath = [cacheDir stringByAppendingPathComponent:[QDUtils md5Hash:url.absoluteString]];
    return [NSURL fileURLWithPath:tmpPath];
}

@end

@implementation QDThemeMgr (iPhoneQDThemeMgr)
- (void)loadiPhoneCSSStyle{
    if (_resourcePathsBlock) {
        NSArray* paths = _resourcePathsBlock();
        for (NSString* path in paths) {
            if ([path hasPrefix:@"http"]) { //来自网络
                ThemeLock();
                WeakSelf;
                NSURLSessionDownloadTask* task = [self.sessionManager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]] progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    return [self cacheURLPath:targetPath];
                } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    StrongSelf;
                    NSDictionary* parentDic = [[[NICSSParser alloc] init] dictionaryForPath:[filePath path]];
                    [self rebuildThemeDictionary:parentDic];
                    ThemeUnlock();
                }];
                [task resume];
            } else {
                NSDictionary* parentDic = [[[NICSSParser alloc] init] dictionaryForPath:path];
                [self rebuildThemeDictionary:parentDic];
            }
        }
    }
}

- (NSArray*)getiPhoneValueOfProperty:(NSString*)property forSeletor:(NSString *)selector {
    NSArray* result = nil;
    
    NSDictionary* childThemeDic = [_resourceThemeDic objectForKey:selector];
    if (childThemeDic) {
        result = [childThemeDic objectForKey:property];
    }
    
    return [self constantsValueForArray:result];
}

@end
