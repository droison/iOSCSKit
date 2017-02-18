//
//  NSURL+CSParams.h
//  CSKit
//
//  Created by song on 2017/1/13.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (CSParams)
@property (nonatomic, strong) NSDictionary *cs_parameters;
+ (NSURL*) URLWithString:(NSString*) url queryParameters:(NSDictionary*) params;

+ (NSString*) queryStringFromParameters:(NSDictionary*) params;

- (NSString *)cs_parameterForKey:(NSString *)key;

- (NSString *)cs_firstPath;
@end
