//
//  NSString+QDURLParams.h
//  QDKitDemo
//
//  Created by song on 2017/2/18.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QDURLParams)

- (NSURL*) qd_toURL;
- (NSString *) qd_parameterForKey:(NSString *)key;
- (NSDictionary *)qd_parameters;
- (NSString *)qd_url;
@end
