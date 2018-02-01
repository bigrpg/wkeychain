//
//  WKeyChain.h
//  wkeychain
//
//  Created by wang on 2/1/18.
//  Copyright © 2018 zulong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKeyChain : NSObject

+(NSString * __nullable) find:(NSString * __nonnull) key;
+(BOOL) set:(NSString * __nonnull) key  data:(NSString* __nullable) data;

+(NSString * __nullable) find:(NSString * __nonnull) key  group:(NSString* __nullable) group;
+(BOOL) set:(NSString * __nonnull) key  data:(NSString* __nullable) data group:(NSString* __nullable) group;

+(NSArray * __nonnull) findAll:(NSString* __nullable) group;

@end
