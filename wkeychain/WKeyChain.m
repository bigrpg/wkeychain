//
//  WKeyChain.m
//  wkeychain
//
//  Created by yuanming wang on 2/1/18.
//  Copyright © 2018 zulong. All rights reserved.
//

#import "WKeyChain.h"

@implementation WKeyChain

#define WKEYCHAIN_ACCOUNT(key)  (key)
#define WKEYCHAIN_GENERIC(key)  (key)



+(NSData * __nullable) findData:(NSString * __nonnull) key  group:(NSString* __nullable) group
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
        NSData * data  = (__bridge_transfer NSData*)dataRef;
        return data;
    }
    return nil;
}

+(NSString *) find:(NSString *) key  group:(NSString*) group
{
    NSData * data = [WKeyChain findData:key group:group];
    if(data == nil)
        return nil;
    NSString * value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return value;
}

//data: nil means remove item
+(BOOL) setData:(NSString *) key  value:(NSData* ) value  group:(NSString*) group
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
        if(value == nil) //remove
        {
            OSStatus deleteState = SecItemDelete((__bridge CFDictionaryRef)queryDict);
            if (deleteState == errSecSuccess) {
                NSLog(@"remove success");
                return YES;
            }
        }
        else
        {
            NSDictionary *paramSetDict = @{
                                        (__bridge id)kSecValueData:value
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
        if(value != nil)
        {
            if(group != nil)
            {
                queryDict = @{
                           (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                           (__bridge id)kSecAttrAccount:WKEYCHAIN_ACCOUNT(key),
                           (__bridge id)kSecAttrGeneric:WKEYCHAIN_GENERIC(key),
                           (__bridge id)kSecValueData:value,
                           (__bridge id)kSecAttrAccessGroup:group
                        };
            }
            else
            {
                queryDict = @{
                         (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                         (__bridge id)kSecAttrAccount:WKEYCHAIN_ACCOUNT(key),
                         (__bridge id)kSecAttrGeneric:WKEYCHAIN_GENERIC(key),
                         (__bridge id)kSecValueData:value,
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

+(BOOL) set:(NSString *) key  value:(NSString* ) value group:(NSString*) group
{
    NSData * data = nil;
    if(value != nil)
        data = [value dataUsingEncoding:NSUTF8StringEncoding];
    return [WKeyChain setData:key value:data group:group];
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

+(NSDictionary * __nullable) getAllData:(NSString* __nullable) group
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
            [retDict setObject:data forKey:key];
        }
        return retDict;
    }
    else if(state == errSecItemNotFound)
    {
        return retDict;
    }
    return nil;
}

+(NSDictionary * __nullable) getAll:(NSString* __nullable) group
{
    NSDictionary * dict = [WKeyChain getAllData:group];
    if(dict != nil)
    {
        NSMutableDictionary * retDict = [[NSMutableDictionary alloc] init];
        for(id key in dict)
        {
            NSData * data = [dict objectForKey:key];
            NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [retDict setObject:value forKey:key];
        }
        return retDict;
    }
    return nil;
}

@end
