//
//  NSString+QDURLParams.m
//  QDKitDemo
//
//  Created by song on 2017/2/18.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "NSString+QDURLParams.h"
#import <objc/runtime.h>
#import "NSURL+QDParams.h"

static void *kNSStringURLParametersDictionaryKey;
static void *kNSStringURLUrlKey;

@implementation NSString (QDURLParams)

- (void)scanParameters {
    
    NSScanner *scanner = [NSScanner scannerWithString: self];
    [scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString:@"&?"] ];
    //skip to ?
    NSString* url;
    [scanner scanUpToString:@"?" intoString: &url];
    if (url) {
        self.qd_url = url;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *tmpValue;
    while ([scanner scanUpToString:@"&" intoString:&tmpValue]) {
        
        NSArray *components = [tmpValue componentsSeparatedByString:@"="];
        
        if (components.count >= 2) {
            NSString *key = [components[0] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            NSString *value = [components[1] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            
            parameters[key]=value;
        }
    }
    
    self.qd_parameters = parameters;
}

-(NSURL *)qd_toURL {
    return [NSURL URLWithString:self.qd_url queryParameters:self.qd_parameters];
}

- (NSString *)qd_parameterForKey:(NSString *)key {
    return self.qd_parameters[key];
}

-(NSString *)qd_url {
    NSString *result = objc_getAssociatedObject(self, &kNSStringURLUrlKey);
    
    if (!result) {
        [self scanParameters];
    }
    
    return objc_getAssociatedObject(self, &kNSStringURLUrlKey);
}

- (void) setQd_url:(NSString*) url {
    objc_setAssociatedObject(self, &kNSStringURLUrlKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)qd_parameters {
    
    NSDictionary *result = objc_getAssociatedObject(self, &kNSStringURLParametersDictionaryKey);
    
    if (!result) {
        [self scanParameters];
    }
    
    return objc_getAssociatedObject(self, &kNSStringURLParametersDictionaryKey);
}

- (void)setQd_parameters:(NSDictionary *)parameters {
    
    objc_setAssociatedObject(self, &kNSStringURLParametersDictionaryKey, parameters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

@end
