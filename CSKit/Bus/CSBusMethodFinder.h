//
//  CSBusMethodFinder.h
//  droison
//
//  Created by song on 2016/9/28.
//  Copyright © 2016年 droison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSBusListener.h"

@interface CSBusMethodFinder : NSObject
- (NSSet<NSString*>*)getPostThread:(id) obj;

//key为入参type 
- (NSDictionary<NSString*, CSBusListener*>*)getBusListener:(id) obj;
@end
