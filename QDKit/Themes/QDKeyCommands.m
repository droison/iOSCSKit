//
//  QDKeyCommands.m
//  QDKit
//
//  Created by SongChai on 2017/4/2.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDKeyCommands.h"

#if TARGET_OS_SIMULATOR
#import <objc/runtime.h>

void QDSwapInstanceMethods(Class cls, SEL original, SEL replacement)
{
    Method originalMethod = class_getInstanceMethod(cls, original);
    IMP originalImplementation = method_getImplementation(originalMethod);
    const char *originalArgTypes = method_getTypeEncoding(originalMethod);
    
    Method replacementMethod = class_getInstanceMethod(cls, replacement);
    IMP replacementImplementation = method_getImplementation(replacementMethod);
    const char *replacementArgTypes = method_getTypeEncoding(replacementMethod);
    
    if (class_addMethod(cls, original, replacementImplementation, replacementArgTypes)) {
        class_replaceMethod(cls, replacement, originalImplementation, originalArgTypes);
    } else {
        method_exchangeImplementations(originalMethod, replacementMethod);
    }
}

@interface QDKeyCommand : NSObject <NSCopying>

@property (nonatomic, strong) UIKeyCommand *keyCommand;
@property (nonatomic, copy) void (^block)(UIKeyCommand *);

@end

@implementation QDKeyCommand

- (instancetype)initWithKeyCommand:(UIKeyCommand *)keyCommand
                             block:(void (^)(UIKeyCommand *))block
{
    if ((self = [super init])) {
        _keyCommand = keyCommand;
        _block = block;
    }
    return self;
}

- (id)copyWithZone:(__unused NSZone *)zone
{
    return self;
}

- (NSUInteger)hash
{
    return _keyCommand.input.hash ^ _keyCommand.modifierFlags;
}

- (BOOL)isEqual:(QDKeyCommand *)object
{
    if (![object isKindOfClass:[QDKeyCommand class]]) {
        return NO;
    }
    return [self matchesInput:object.keyCommand.input
                        flags:object.keyCommand.modifierFlags];
}

- (BOOL)matchesInput:(NSString *)input flags:(UIKeyModifierFlags)flags
{
    return [_keyCommand.input isEqual:input] && _keyCommand.modifierFlags == flags;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p input=\"%@\" flags=%zd hasBlock=%@>",
            [self class], self, _keyCommand.input, _keyCommand.modifierFlags,
            _block ? @"YES" : @"NO"];
}

@end

@interface QDKeyCommands ()

@property (nonatomic, strong) NSMutableSet<QDKeyCommand *> *commands;

@end

@implementation UIResponder (QDKeyCommands)

- (NSArray<UIKeyCommand *> *)QD_keyCommands
{
    NSSet<QDKeyCommand *> *commands = [QDKeyCommands sharedInstance].commands;
    return [[commands valueForKeyPath:@"keyCommand"] allObjects];
}

- (void)QD_handleKeyCommand:(UIKeyCommand *)key
{
    // NOTE: throttle the key handler because on iOS 9 the handleKeyCommand:
    // method gets called repeatedly if the command key is held down.
    static NSTimeInterval lastCommand = 0;
    if (CACurrentMediaTime() - lastCommand > 0.5) {
        for (QDKeyCommand *command in [QDKeyCommands sharedInstance].commands) {
            if ([command.keyCommand.input isEqualToString:key.input] &&
                command.keyCommand.modifierFlags == key.modifierFlags) {
                if (command.block) {
                    command.block(key);
                    lastCommand = CACurrentMediaTime();
                }
            }
        }
    }
}

@end


@implementation QDKeyCommands

+ (void)initialize
{
    QDSwapInstanceMethods([UIResponder class],
                           @selector(keyCommands),
                           @selector(QD_keyCommands));
}

+ (instancetype)sharedInstance
{
    static QDKeyCommands *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _commands = [NSMutableSet new];
    }
    return self;
}

- (void)registerKeyCommandWithInput:(NSString *)input
                      modifierFlags:(UIKeyModifierFlags)flags
                             action:(void (^)(UIKeyCommand *))block
{
    UIKeyCommand *command = [UIKeyCommand keyCommandWithInput:input
                                                modifierFlags:flags
                                                       action:@selector(QD_handleKeyCommand:)];
    
    QDKeyCommand *keyCommand = [[QDKeyCommand alloc] initWithKeyCommand:command block:block];
    [_commands removeObject:keyCommand];
    [_commands addObject:keyCommand];
}

@end

#else

@implementation QDKeyCommands

+ (instancetype)sharedInstance
{
    return nil;
}

- (void)registerKeyCommandWithInput:(NSString *)input
                      modifierFlags:(UIKeyModifierFlags)flags
                             action:(void (^)(UIKeyCommand *))block {}
@end

#endif
