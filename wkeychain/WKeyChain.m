//
//  WKeyChain.m
//  wkeychain
//
//  Created by yuanming wang on 2/1/18.
//  Copyright © 2018 zulong. All rights reserved.
//

#import "WKeyChain.h"

@implementation WKeyChain

#define WKEYCHAIN_ACCOUNT(key)  key
#define WKEYCHAIN_GENERIC(key)  key

+(NSString * __nullable) find:(NSString * __nonnull) key
{
    return [WKeyChain find:key group:nil];
}

+(BOOL) set:(NSString * __nonnull) key  data:(NSString* __nullable) data
{
    return [WKeyChain set:key data:data group:nil];
}

+(BOOL) clear
{
    return [WKeyChain clear:nil];
}

+(NSDictionary * __nullable) findAll
{
    return [WKeyChain findAll:nil];
}

+(NSString *) find:(NSString *) key  group:(NSString*) group
{
    //query dictionary
    NSDictionary *queryDict = nil;
    if( group != nil)
    {
        queryDict = @{
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
        queryDict = @{
                        (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                        (__bridge id)kSecAttrAccount:WKEYCHAIN_ACCOUNT(key),
                        (__bridge id)kSecAttrGeneric:WKEYCHAIN_GENERIC(key),
                        (__bridge id)kSecReturnData:(__bridge id)kCFBooleanTrue,
                        (__bridge id)kSecMatchLimit : (__bridge id)kSecMatchLimitOne
                      };
    }
    //
    
    CFDataRef dataRef = NULL;
    OSStatus state = SecItemCopyMatching((__bridge CFDictionaryRef)queryDict, (CFTypeRef*)&dataRef);
    if (state == errSecSuccess) {
        NSString * data  = [[NSString alloc] initWithData:(__bridge_transfer NSData*)dataRef encoding:NSUTF8StringEncoding];
        return data;
    }
    return nil;
}

+(BOOL) set:(NSString *) key  data:(NSString* ) data group:(NSString*) group
{
    //query dictionary
    NSDictionary *queryDict = nil;
    if( group != nil)
    {
        queryDict  = @{
                        (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                        (__bridge id)kSecAttrAccount:WKEYCHAIN_ACCOUNT(key),
                        (__bridge id)kSecAttrGeneric:WKEYCHAIN_GENERIC(key),
                        (__bridge id)kSecAttrAccessGroup:group,
                      };
    }
    else
    {
        queryDict  = @{
                        (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                        (__bridge id)kSecAttrAccount:WKEYCHAIN_ACCOUNT(key),
                        (__bridge id)kSecAttrGeneric:WKEYCHAIN_GENERIC(key),
                      };
    }
    //
    
    OSStatus state = SecItemCopyMatching((__bridge CFDictionaryRef)queryDict, NULL);
    //exist
    if (state == errSecSuccess) {
        if(data == nil) //remove
        {
            OSStatus deleteState = SecItemDelete((__bridge CFDictionaryRef)queryDict);
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
            OSStatus updateState = SecItemUpdate((__bridge CFDictionaryRef)queryDict, (__bridge CFDictionaryRef)paramSetDict);
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
                queryDict = @{
                           (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                           (__bridge id)kSecAttrAccount:WKEYCHAIN_ACCOUNT(key),
                           (__bridge id)kSecAttrGeneric:WKEYCHAIN_GENERIC(key),
                           (__bridge id)kSecValueData:newData,
                           (__bridge id)kSecAttrAccessGroup:group
                        };
            }
            else
            {
                queryDict = @{
                         (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                         (__bridge id)kSecAttrAccount:WKEYCHAIN_ACCOUNT(key),
                         (__bridge id)kSecAttrGeneric:WKEYCHAIN_GENERIC(key),
                         (__bridge id)kSecValueData:newData,
                         };
            }
            CFTypeRef typeResult = NULL;
            OSStatus state =  SecItemAdd((__bridge CFDictionaryRef)queryDict, &typeResult);
            if (state == errSecSuccess) {
                NSLog(@"add secceed");
                return YES;
            }
        }
    }
    return NO;
}

+(BOOL) clear:(NSString* __nullable) group
{

    /*当为kSecMatchLimit时，SecItemCopyMatching第二个参数为CFArrayRef，元素为CFDataRef*/
    NSDictionary *queryDict = nil;
    if(group != nil)
    {
        queryDict = @{
                        (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                        (__bridge id)kSecReturnData:(__bridge id)kCFBooleanTrue,
                        (__bridge id)kSecAttrAccessGroup:group
                    };
    }
    else
    {
        queryDict = @{
                      (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                      (__bridge id)kSecReturnData:(__bridge id)kCFBooleanTrue
                    };
    }
    
    OSStatus deleteState = SecItemDelete((__bridge CFDictionaryRef)queryDict);
    if (deleteState == errSecSuccess) {
        NSLog(@"clear success");
        return YES;
    }
    else if(deleteState == errSecItemNotFound)
    {
        return YES;
    }
    
    return NO;
}

+(NSDictionary * __nullable) findAll:(NSString* __nullable) group
{
    /*当为kSecMatchLimit时，SecItemCopyMatching第二个参数为CFArrayRef，元素为CFDataRef*/
    NSDictionary *queryDict = nil;
    if(group != nil)
    {
        queryDict = @{
                      (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                      (__bridge id)kSecReturnRef : (__bridge id)kCFBooleanTrue,
                      (__bridge id)kSecReturnData:(__bridge id)kCFBooleanTrue,
                      (__bridge id)kSecAttrAccessGroup:group,
                      (__bridge id)kSecMatchLimit : (__bridge id)kSecMatchLimitAll
                    };
    }
    else
    {
        queryDict = @{
                      (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                      (__bridge id)kSecReturnRef : (__bridge id)kCFBooleanTrue,
                      (__bridge id)kSecReturnData:(__bridge id)kCFBooleanTrue,
                      (__bridge id)kSecMatchLimit : (__bridge id)kSecMatchLimitAll
                    };
    }
    
    CFArrayRef arrayRef = NULL;
    NSMutableDictionary * retDict = [[NSMutableDictionary alloc] init];
    OSStatus state = SecItemCopyMatching((__bridge CFDictionaryRef)queryDict, (CFTypeRef*)&arrayRef);
    if (state == errSecSuccess) {
        NSArray *arrays = CFBridgingRelease(arrayRef);
        for(NSUInteger i=0;i<[arrays count];++i)
        {
            CFTypeRef dataRef = (__bridge CFTypeRef)[arrays objectAtIndex:i];
            NSDictionary *dict = (__bridge NSDictionary *)dataRef;
            NSString *key = dict[(id)kSecAttrGeneric];
            //NSString * account = dict[(id)kSecAttrAccount];
            NSData *data = dict[(id)kSecValueData];
            NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [retDict setObject:value forKey:key];
        }
    }
    else if(state == errSecItemNotFound)
    {
        return retDict;
    }
    return nil;
}

@end
