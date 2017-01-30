//
//  CSBusParserUtils.h
//  CSKit
//
//  Created by song on 16/11/28.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CServiceCenter.h"

@interface CSBusParserUtils : NSObject

/**
 * Generic utility functions for parsing Objective-C source code.
 */
CS_EXTERN BOOL CSReadChar(const char **input, char c);
CS_EXTERN BOOL CSReadString(const char **input, const char *string);
CS_EXTERN void CSkipWhitespace(const char **input);
CS_EXTERN BOOL CSParseIdentifier(const char **input, NSString **string);

/**
 * Parse an Objective-C type into a form that can be used by RCTConvert.
 * This doesn't really belong here, but it's used by both RCTConvert and
 * RCTModuleMethod, which makes it difficult to find a better home for it.
 */
CS_EXTERN NSString *QParseType(const char **input);

@end
