//
//  NSURL+CSParams.h
//  CSKitDemo
//
//  Created by song on 2017/1/13.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (CSParams)
+ (NSURL*) URLWithString:(NSString*) url queryParameters:(NSDictionary*) params;

+ (NSString*) queryStringFromParameters:(NSDictionary*) params;

- (NSString *)parameterForKey:(NSString *)key;

- (NSDictionary *)parameters;

- (NSString *)firstPath;
@end
