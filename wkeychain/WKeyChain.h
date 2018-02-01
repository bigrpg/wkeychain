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
+(NSString * __nullable) find:(NSString * __nonnull) key  group:(NSString* __nullable) group;

+(BOOL) set:(NSString * __nonnull) key  data:(NSString* __nullable) data;
+(BOOL) set:(NSString * __nonnull) key  data:(NSString* __nullable) data group:(NSString* __nullable) group;

+(BOOL) clear;
+(BOOL) clear:(NSString* __nullable) group;

//return nil means error occurs
+(NSDictionary * __nullable) findAll;
+(NSDictionary * __nullable) findAll:(NSString* __nullable) group;

@end
