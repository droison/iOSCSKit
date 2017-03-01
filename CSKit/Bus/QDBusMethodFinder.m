//
//  QDBusMethodFinder.m
//  CSKit
//
//  Created by song on 2016/9/28.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDBusMethodFinder.h"
#import <objc/runtime.h>
#import "QDBusParserUtils.h"

NSString * const QDBusPostCurrentThreadMethodPrefixString = @"__busthread_export__";

NSString * const QDBusListenerThreadMethodPrefixString = @"__bus_listener_thread_export__";

NSString * const QDBusKeyPostCurrentThread = @"QDBusKeyPostCurrentThread";
NSString * const QDBusKeyListenerCurrentThread = @"QDBusKeyListenerCurrentThread";
NSString * const QDBusKeyListenerMainThread = @"QDBusKeyListenerMainThread";


@implementation QDBusMethodFinder {
    NSMapTable<Class, NSDictionary<NSString*, NSSet<NSString*>*>*>* _methodCache;
    NSMapTable<Class, NSDictionary<NSString*, QDBusMethod*>*>* _listenerMethodCache; //class -- (arguments --- QDBusMethod)
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _methodCache = [NSMapTable strongToStrongObjectsMapTable];
        _listenerMethodCache = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

- (NSSet<NSString*>*)getPostThread:(id) obj {
    Class targetClass = [obj class];
    NSDictionary<NSString*, NSSet<NSString*>*>* targetClassMethd = [_methodCache objectForKey:targetClass];
    if (targetClassMethd == nil) {
        [self loadMethod:targetClass];
    }
    targetClassMethd = [_methodCache objectForKey:targetClass];
    return [targetClassMethd objectForKey:QDBusKeyPostCurrentThread];
}

- (NSDictionary<NSString*, QDBusListener*>*)getBusListener:(id) obj {
    NSDictionary<NSString*, QDBusMethod*>* currentClassListenerMethod = [_listenerMethodCache objectForKey:[obj class]];
    if (currentClassListenerMethod == nil) {
        [self loadMethod:[obj class]];
    }
    currentClassListenerMethod = [_listenerMethodCache objectForKey:[obj class]];
    NSMutableDictionary<NSString*, QDBusListener*>* result = [NSMutableDictionary dictionaryWithCapacity:currentClassListenerMethod.count];
    [currentClassListenerMethod enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, QDBusMethod * _Nonnull method, BOOL * _Nonnull stop) {
        [result setObject:[[QDBusListener alloc] initWithTarget:obj method:method] forKey:key];
    }];
    return result;
}

- (void)loadMethod:(Class) targetClass {
    
    //post
    NSMutableDictionary<NSString*, NSSet<NSString*>*>* curClassMethd = [NSMutableDictionary new];
    //default mainThreadMethod 所以不处理
    NSMutableSet<NSString*>* postThreadMethod = [NSMutableSet new];
    [curClassMethd setObject:postThreadMethod forKey:QDBusKeyPostCurrentThread];
    
    //listener
    NSMutableDictionary<NSString*, QDBusMethod*>* listenerClassMethod = [NSMutableDictionary new];
    

    unsigned int methodCount;
    Class cls = targetClass;
    NSString* clsName = NSStringFromClass(cls);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    while (cls && ![clsName hasPrefix:@"NS"] && ![clsName hasPrefix:@"UI"] && cls != [NSObject class] && cls != [NSProxy class]) {
        Method *methods = class_copyMethodList(object_getClass(cls), &methodCount);
        for (unsigned int i = 0; i < methodCount; i++) {
            Method method = methods[i];
            SEL selector = method_getName(method);
            if ([NSStringFromSelector(selector) hasPrefix:QDBusPostCurrentThreadMethodPrefixString]) {
                NSArray* array = [cls performSelector:selector];
                NSArray<NSString *> *arguments;
                SEL realSelector  = CSParseMethodSignature(array[1], &arguments);
                [postThreadMethod addObject:NSStringFromSelector(realSelector)];
            } else if ([NSStringFromSelector(selector) hasPrefix:QDBusListenerThreadMethodPrefixString]) {
                NSArray* array = [cls performSelector:selector];
                NSArray<NSString *> *arguments;
                SEL realSelector  = CSParseMethodSignature(array[1], &arguments);
                if (arguments && arguments.count == 1) { //有且只有1个入参才可以，相同类型入参有且只有一个方法能接受参数
                    QDBusThread thread = QDBusThreadCurrent;
                    if ([array[0] isEqualToString:@"main"]) {
                        thread = QDBusThreadMain;
                    }
                    QDBusMethod* busMethod = [[QDBusMethod alloc] initWithClass:targetClass sel:realSelector type:arguments[0] thread:thread];
                    [listenerClassMethod setObject:busMethod forKey:arguments[0]];
                }
            }
        }
        
        free(methods);
        cls = class_getSuperclass(cls);
        clsName = NSStringFromClass(cls);
    }
#pragma clang diagnostic pop
    
    [_methodCache setObject:curClassMethd forKey:targetClass];
    [_listenerMethodCache setObject:listenerClassMethod forKey:targetClass];
    

}

static BOOL CSParseSelectorPart(const char **input, NSMutableString *selector)
{
    NSString *selectorPart;
    if (CSParseIdentifier(input, &selectorPart)) {
        [selector appendString:selectorPart];
    }
    CSkipWhitespace(input);
    if (CSReadChar(input, ':')) {
        [selector appendString:@":"];
        CSkipWhitespace(input);
        return YES;
    }
    return NO;
}

SEL CSParseMethodSignature(NSString *, NSArray<NSString *> **);
SEL CSParseMethodSignature(NSString *methodSignature, NSArray<NSString *> **arguments)
{
    const char *input = methodSignature.UTF8String;
    CSkipWhitespace(&input);
    
    NSMutableArray *args;
    NSMutableString *selector = [NSMutableString new];
    while (CSParseSelectorPart(&input, selector)) {
        if (!args) {
            args = [NSMutableArray new];
        }
        
        // Parse type
        if (CSReadChar(&input, '(')) {
            CSkipWhitespace(&input);
            
            CSkipWhitespace(&input);
            
            CSkipWhitespace(&input);
            
            NSString *type = QParseType(&input);
            CSkipWhitespace(&input);
            
            [args addObject:type];
            CSkipWhitespace(&input);
            CSReadChar(&input, ')');
            CSkipWhitespace(&input);
        } else {
            // Type defaults to id if unspecified
            [args addObject:@"id"];
        }
        
        // Argument name
        CSParseIdentifier(&input, NULL);
        CSkipWhitespace(&input);
    }
    
    *arguments = [args copy];
    return NSSelectorFromString(selector);
}
@end
