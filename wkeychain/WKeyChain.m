//
//  WKeyChain.m
//  wkeychain
//
//  Created by wang on 2/1/18.
//  Copyright © 2018 zulong. All rights reserved.
//

#import "WKeyChain.h"

@implementation WKeyChain

#define WKEYCHAIN_ACCOUNT(key)  @"100"
#define WKEYCHAIN_GENERIC(key)  key

+(NSString * __nullable) find:(NSString * __nonnull) key
{
    return [WKeyChain find:key group:nil];
}
+(BOOL) set:(NSString * __nonnull) key  data:(NSString* __nullable) data
{
    return [WKeyChain set:key data:data group:nil];
}

+(NSString *) find:(NSString *) key  group:(NSString*) group
{
    NSString * data = nil;
    NSDictionary *queueDict = nil;
    
    if( group != nil)
    {
        queueDict = @{
                        (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                        (__bridge id)kSecAttrAccount:WKEYCHAIN_ACCOUNT(key),
                        (__bridge id)kSecAttrGeneric:WKEYCHAIN_GENERIC(key),
                        (__bridge id)kSecReturnData:(__bridge id)kCFBooleanTrue,
                        (__bridge id)kSecAttrAccessGroup:group,
                        (__bridge id)kSecMatchLimit : (__bridge id)kSecMatchLimitOne
                    };
    }
    else
    {
        queueDict = @{
                        (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                        (__bridge id)kSecAttrAccount:WKEYCHAIN_ACCOUNT(key),
                        (__bridge id)kSecAttrGeneric:WKEYCHAIN_GENERIC(key),
                        (__bridge id)kSecReturnData:(__bridge id)kCFBooleanTrue,
                        (__bridge id)kSecMatchLimit : (__bridge id)kSecMatchLimitOne
                      };
    }
    
    CFDataRef dataRef = NULL;
    OSStatus state = SecItemCopyMatching((__bridge CFDictionaryRef)queueDict, (CFTypeRef*)&dataRef);
    if (state == errSecSuccess) {
        data  = [[NSString alloc] initWithData:(__bridge_transfer NSData*)dataRef encoding:NSUTF8StringEncoding];
        NSLog(@"data:%@",data);
    }
    return data;
}

+(BOOL) set:(NSString *) key  data:(NSString* ) data group:(NSString*) group
{
    NSDictionary *queueDict = nil;
    if( group != nil)
    {
        queueDict  = @{
                        (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                        (__bridge id)kSecAttrAccount:WKEYCHAIN_ACCOUNT(key),
                        (__bridge id)kSecAttrGeneric:WKEYCHAIN_GENERIC(key),
                        (__bridge id)kSecAttrAccessGroup:group,
                        };
    }
    else
    {
        queueDict  = @{
                       (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                       (__bridge id)kSecAttrAccount:WKEYCHAIN_ACCOUNT(key),
                       (__bridge id)kSecAttrGeneric:WKEYCHAIN_GENERIC(key),
                       };
    }
    
    OSStatus state = SecItemCopyMatching((__bridge CFDictionaryRef)queueDict, NULL);
    //exist
    if (state == errSecSuccess) {
        if(data == nil) //remove
        {
            OSStatus deleteState = SecItemDelete((__bridge CFDictionaryRef)queueDict);
            if (deleteState == errSecSuccess) {
                NSLog(@"remove success");
                return YES;
            }
        }
        else
        {
            NSData *newData = [data dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *paramSetDict = @{
                                        (__bridge id)kSecValueData:newData
                                        };
            OSStatus updateState = SecItemUpdate((__bridge CFDictionaryRef)queueDict, (__bridge CFDictionaryRef)paramSetDict);
            if (updateState == errSecSuccess) {
                NSLog(@"update success");
                return YES;
            }
        }
    }
    else //add new keychain item
    {
        if(data != nil)
        {
            NSData *newData = [data dataUsingEncoding:NSUTF8StringEncoding];
            
            if(group != nil)
            {
                queueDict = @{
                           (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                           (__bridge id)kSecAttrAccount:WKEYCHAIN_ACCOUNT(key),
                           (__bridge id)kSecAttrGeneric:WKEYCHAIN_GENERIC(key),
                           (__bridge id)kSecValueData:newData,
                           (__bridge id)kSecAttrAccessGroup:group
                        };
            }
            else
            {
                queueDict = @{
                         (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                         (__bridge id)kSecAttrAccount:WKEYCHAIN_ACCOUNT(key),
                         (__bridge id)kSecAttrGeneric:WKEYCHAIN_GENERIC(key),
                         (__bridge id)kSecValueData:newData,
                         };
            }
            CFTypeRef typeResult = NULL;
            OSStatus state =  SecItemAdd((__bridge CFDictionaryRef)queueDict, &typeResult);
            if (state == errSecSuccess) {
                NSLog(@"add secceed");
                return YES;
            }
        }
    }
    return NO;
}

@end
