//
//  QDBusParserUtils.m
//  CSKit
//
//  Created by song on 16/11/28.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDBusParserUtils.h"

@implementation QDBusParserUtils

BOOL CSReadChar(const char **input, char c)
{
    if (**input == c) {
        (*input)++;
        return YES;
    }
    return NO;
}

BOOL CSReadString(const char **input, const char *string)
{
    int i;
    for (i = 0; string[i] != 0; i++) {
        if (string[i] != (*input)[i]) {
            return NO;
        }
    }
    *input += i;
    return YES;
}

void CSkipWhitespace(const char **input)
{
    while (isspace(**input)) {
        (*input)++;
    }
}

static BOOL QIsIdentifierHead(const char c)
{
    return isalpha(c) || c == '_';
}

static BOOL QIsIdentifierTail(const char c)
{
    return isalnum(c) || c == '_';
}

BOOL CSParseIdentifier(const char **input, NSString **string)
{
    const char *start = *input;
    if (!QIsIdentifierHead(**input)) {
        return NO;
    }
    (*input)++;
    while (QIsIdentifierTail(**input)) {
        (*input)++;
    }
    if (string) {
        *string = [[NSString alloc] initWithBytes:start
                                           length:(NSInteger)(*input - start)
                                         encoding:NSASCIIStringEncoding];
    }
    return YES;
}

static BOOL QIsCollectionType(NSString *type)
{
    static NSSet *collectionTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        collectionTypes = [[NSSet alloc] initWithObjects:
                           @"NSArray", @"NSSet", @"NSDictionary", nil];
    });
    return [collectionTypes containsObject:type];
}

NSString *QParseType(const char **input)
{
    NSString *type;
    CSParseIdentifier(input, &type);
    CSkipWhitespace(input);
    if (CSReadChar(input, '<')) {
        CSkipWhitespace(input);
        NSString *subtype = QParseType(input);
        if (QIsCollectionType(type)) {
            if ([type isEqualToString:@"NSDictionary"]) {
                // Dictionaries have both a key *and* value type, but the key type has
                // to be a string for JSON, so we only care about the value type
                if (![subtype isEqualToString:@"NSString"]) {
                    CSLog(@"QDBusParserUtils -- %@ is not a valid key type for a JSON dictionary", subtype);
                }
                CSkipWhitespace(input);
                CSReadChar(input, ',');
                CSkipWhitespace(input);
                subtype = QParseType(input);
            }
            if (![subtype isEqualToString:@"id"]) {
                type = [type stringByReplacingCharactersInRange:(NSRange){0, 2 /* "NS" */}
                                                     withString:subtype];
            }
        } else {
            // It's a protocol rather than a generic collection - ignore it
            type = subtype;
        }
        CSkipWhitespace(input);
        CSReadChar(input, '>');
    }
    CSkipWhitespace(input);
    CSReadChar(input, '*');
    return type;
}

@end
