//
//  QDBusMethodFinder.h
//  QDKit
//
//  Created by song on 2016/9/28.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QDBusListener.h"

@interface QDBusMethodFinder : NSObject
- (NSSet<NSString*>*)getPostThread:(id) obj;

//key为入参type 
- (NSDictionary<NSString*, QDBusListener*>*)getBusListener:(id) obj;
@end
