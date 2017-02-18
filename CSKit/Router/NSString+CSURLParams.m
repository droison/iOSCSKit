//
//  NSString+CSURLParams.m
//  CSKitDemo
//
//  Created by song on 2017/2/18.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "NSString+CSURLParams.h"
#import <objc/runtime.h>
#import "NSURL+CSParams.h"

static void *kNSStringURLParametersDictionaryKey;
static void *kNSStringURLUrlKey;

@implementation NSString (CSURLParams)

- (void)scanParameters {
    
    NSScanner *scanner = [NSScanner scannerWithString: self];
    [scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString:@"&?"] ];
    //skip to ?
    NSString* url;
    [scanner scanUpToString:@"?" intoString: &url];
    if (url) {
        self.cs_url = url;
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
    
    self.cs_parameters = parameters;
}

-(NSURL *)cs_toURL {
    return [NSURL URLWithString:self.cs_url queryParameters:self.cs_parameters];
}

- (NSString *)cs_parameterForKey:(NSString *)key {
    return self.cs_parameters[key];
}

-(NSString *)cs_url {
    NSString *result = objc_getAssociatedObject(self, &kNSStringURLUrlKey);
    
    if (!result) {
        [self scanParameters];
    }
    
    return objc_getAssociatedObject(self, &kNSStringURLUrlKey);
}

- (void) setCs_url:(NSString*) url {
    objc_setAssociatedObject(self, &kNSStringURLUrlKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)cs_parameters {
    
    NSDictionary *result = objc_getAssociatedObject(self, &kNSStringURLParametersDictionaryKey);
    
    if (!result) {
        [self scanParameters];
    }
    
    return objc_getAssociatedObject(self, &kNSStringURLParametersDictionaryKey);
}

- (void)setCs_parameters:(NSDictionary *)parameters {
    
    objc_setAssociatedObject(self, &kNSStringURLParametersDictionaryKey, parameters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

@end
