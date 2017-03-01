//
//  NSURL+QDParams.h
//  QDKit
//
//  Created by song on 2017/1/13.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (QDParams)
@property (nonatomic, strong) NSDictionary *qd_parameters;
+ (NSURL*) URLWithString:(NSString*) url queryParameters:(NSDictionary*) params;

+ (NSString*) queryStringFromParameters:(NSDictionary*) params;

- (NSString *)qd_parameterForKey:(NSString *)key;

- (NSString *)qd_firstPath;
@end
