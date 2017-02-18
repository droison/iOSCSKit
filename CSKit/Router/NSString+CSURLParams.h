//
//  NSString+CSURLParams.h
//  CSKitDemo
//
//  Created by song on 2017/2/18.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CSURLParams)
- (NSURL*) cs_toURL;
- (NSString *) cs_parameterForKey:(NSString *)key;
- (NSDictionary *) cs_parameters;
- (NSString *) cs_url;
@end
