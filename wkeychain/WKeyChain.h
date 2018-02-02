//
//  WKeyChain.h
//  wkeychain
//
//  Created by yuanming wang on 2/1/18.
//  Copyright © 2018 zulong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKeyChain : NSObject


+(NSString * __nullable) find:(NSString * __nonnull)     key  group:(NSString* __nullable) group;
+(NSData * __nullable)   findData:(NSString * __nonnull) key  group:(NSString* __nullable) group;

+(BOOL) set     :(NSString * __nonnull) key  value:(NSString* __nullable)   value group:(NSString* __nullable) group;
+(BOOL) setData :(NSString * __nonnull) key  value:(NSData* __nullable)     value group:(NSString* __nullable) group;

//return nil means error occurs
+(NSDictionary * __nullable) getAllData:(NSString* __nullable)  group;
+(NSDictionary * __nullable) getAll:(NSString* __nullable)      group;

+(BOOL) clear:(NSString* __nullable) group;

@end
