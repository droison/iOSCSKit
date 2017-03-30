//
//  QDServiceHashMap.h
//  QDKitDemo
//
//  Created by SongChai on 2017/3/30.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDServiceCenter.h"

@interface QDServiceHashMap : NSObject

@property(nonatomic, strong, readonly) QDService* headerService;

- (void)setObject:(QDService<QDService>*)anObject forKey:(Class)aKey;
- (QDService<QDService>*)objectForKey:(Class)aKey;
- (void)removeObjectForKey:(Class)aKey;
- (void)removeAllObjects;

- (NSArray<QDService<QDService>*>*) allValues;
@end
