//
//  QDUtils.m
//  QDKitDemo
//
//  Created by SongChai on 2017/4/4.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDUtils.h"
#import "QDKitMacro.h"
#import <CommonCrypto/CommonDigest.h>

@implementation QDUtils

+ (NSString *)md5Hash:(NSString*)str {
    if (CSEmptyString(str)) {
        return @"";
    }
    
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (int)[data length], result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

@end
