//
//  NSURL+CSParams.m
//  CSKitDemo
//
//  Created by song on 2017/1/13.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "NSURL+CSParams.h"
#import <objc/runtime.h>

static void *kURLParametersDictionaryKey;

static NSString * const kQHCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

static NSString * QHPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kQHCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";
    
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kQHCharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)kQHCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

static NSString * QHPercentEscapedQueryStringValueFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)kQHCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

@interface QHQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (id)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;
@end

@implementation QHQueryStringPair

- (id)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return QHPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding);
    } else {
        return [NSString stringWithFormat:@"%@=%@", QHPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding), QHPercentEscapedQueryStringValueFromStringWithEncoding([self.value description], stringEncoding)];
    }
}

@end

#pragma mark -

extern NSArray * QHQueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSArray * QHQueryStringPairsFromKeyAndValue(NSString *key, id value);

static NSString * QHQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (QHQueryStringPair *pair in QHQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValueWithEncoding:stringEncoding]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * QHQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return QHQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * QHQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = [dictionary objectForKey:nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:QHQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:QHQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:QHQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[QHQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}

@implementation NSURL (CSParams)
+ (NSURL*) URLWithString:(NSString*) url queryParameters:(NSDictionary*) params {
    NSString* queryString = [NSURL queryStringFromParameters:params];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", url, queryString]];
}

+ (NSString*) queryStringFromParameters:(NSDictionary*) params {
    if (params && params.count > 0) {
        return QHQueryStringFromParametersWithEncoding(params, NSUTF8StringEncoding);
    }
    return @"";
}

- (void)scanParameters {
    
    if (self.isFileURL) {
        return;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString: self.absoluteString];
    [scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString:@"&?"] ];
    //skip to ?
    [scanner scanUpToString:@"?" intoString: nil];
    
    
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
    
    self.parameters = parameters;
}

- (id)objectForKeyedSubscript:(id)key {
    return self.parameters[key];
}


- (NSString *)parameterForKey:(NSString *)key {
    return self.parameters[key];
}

- (NSString*)firstPath{
    NSArray* paths = [self.path componentsSeparatedByString:@"/"];
    if (paths.count > 1) {
        return paths[1];
    }
    return [paths firstObject];
}

- (NSDictionary *)parameters {
    
    NSDictionary *result = objc_getAssociatedObject(self, &kURLParametersDictionaryKey);
    
    if (!result) {
        [self scanParameters];
    }
    
    return objc_getAssociatedObject(self, &kURLParametersDictionaryKey);
}

- (void)setParameters:(NSDictionary *)parameters {
    
    objc_setAssociatedObject(self, &kURLParametersDictionaryKey, parameters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}
@end
