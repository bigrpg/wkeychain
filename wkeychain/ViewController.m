//
//  ViewController.m
//  wkeychain
//
//  Created by zl on 2018/2/1.
//  Copyright © 2018年 zulong. All rights reserved.
//

#import "ViewController.h"
#import "WKeyChain.h"
#import <Security/Security.h>

@interface ViewController ()

@end

@implementation ViewController

#define  ACCESS_GROUP   (__bridge id)kSecAttrAccessGroup:@"AGD4F38NNV.com.dangsheng.test2"
#define  GROUP    @"AGD4F38NNV.com.dangsheng.test21"
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString * s = @"如果用纯 lua 来做向量/矩阵运算在性能要求很高的场合通常是不可接受的。但即使封装成 C 库，传统的方法也比较重。若把每个 vector 都封装为 userdata ，有效载荷很低。一个 float vector 4 ，本身只有 16 字节，而 userdata 本身需要额外 40 字节来维护；4 阶 float 矩阵也不过 64 字节。更不用说在向量运算过程中大量产生的临时对象所带来的 gc 负担了。";
    
    
    NSString * value = [WKeyChain find:@"hello" group:GROUP];
    NSLog(@"%@",value);
    
    if(value != nil)
        [WKeyChain set:@"hello" data:nil group:GROUP];
    else
        [WKeyChain set:@"hello" data:s group:GROUP];
    value = [WKeyChain find:@"hello" group:GROUP];
    NSLog(@"%@",value);
    
    //[self findDataItems];
    //    [self updateData];
    //    [self findData];
    //    [self findAttr];
    //    [self storeDataTest];
}

-(void)deleteData
{
    NSString *key = @"hello";
    NSString *server = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary *queue = @{
                            (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                            //(__bridge id)kSecAttrService:server,
                            (__bridge id)kSecAttrGeneric:key,
                            //(__bridge id)kSecAttrAccount:@"",
                            ACCESS_GROUP
                            };
    OSStatus state = SecItemCopyMatching((__bridge CFDictionaryRef)queue, NULL);
    //存在
    if (state == errSecSuccess) {
        OSStatus deleteState = SecItemDelete((__bridge CFDictionaryRef)queue);
        if (deleteState == errSecSuccess) {
            NSLog(@"删除成功!!!");
        }
    }
}

-(void)updateData
{
    NSString *key = @"hello";
    NSString *server = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary *queue = @{
                            (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                            //                            (__bridge id)kSecAttrService:server,
                            (__bridge id)kSecAttrGeneric:key,
                            (__bridge id)kSecAttrAccount:@"100",
                            ACCESS_GROUP
                            };
    OSStatus state = SecItemCopyMatching((__bridge CFDictionaryRef)queue, NULL);
    //存在修改
    if (state == errSecSuccess) {
        NSString *newValue = @"new Value";
        NSData *newData = [newValue dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *paramDict = @{
                                    (__bridge id)kSecValueData:newData
                                    };
        OSStatus updateState = SecItemUpdate((__bridge CFDictionaryRef)queue, (__bridge CFDictionaryRef)paramDict);
        if (updateState == errSecSuccess) {
            NSLog(@"更新成功");
        }
    }
}

//存储数据到钥匙串中
-(void)storeData
{
    NSString *key = @"hello";
    NSString *value = @"passwordhello_你好这是个关于keychain的测试";
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary *dict = @{
                           (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                           //(__bridge id)kSecAttrService:service,
                           (__bridge id)kSecAttrAccount:@"100",
                           (__bridge id)kSecAttrGeneric:key,
                           (__bridge id)kSecValueData:valueData,
                           //(__bridge id)kSecAttrLabel:@"",
                           //(__bridge id)kSecAttrDescription:@"",
                           (__bridge id)kSecAttrAccessGroup:@"AGD4F38NNV.com.dangsheng.test2"
                           };
    CFTypeRef typeResult = NULL;
    OSStatus state =  SecItemAdd((__bridge CFDictionaryRef)dict, &typeResult);
    if (state == errSecSuccess) {
        NSLog(@"store secceed");
    }
}

//查找
-(void)findAttr
{
    NSString *key = @"pwd";
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary *dict = @{
                           (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                           (__bridge id)kSecAttrService:service,
                           (__bridge id)kSecAttrAccount:key,
                           (__bridge id)kSecReturnAttributes:(__bridge id)kCFBooleanTrue
                           };
    CFDictionaryRef resultDict = NULL;
    OSStatus state = SecItemCopyMatching((__bridge CFDictionaryRef)dict, (CFTypeRef*)&resultDict);
    NSDictionary *result = (__bridge_transfer NSDictionary*)resultDict;
    if (state == errSecSuccess)
    {
        NSLog(@"server:%@",result[(__bridge id)kSecAttrService]);
        NSLog(@"account:%@",result[(__bridge id)kSecAttrAccount]);
        NSLog(@"assessGroup:%@",result[(__bridge id)kSecAttrAccessGroup]);
        NSLog(@"createDate:%@",result[(__bridge id)kSecAttrCreationDate]);
        NSLog(@"modifyDate:%@",result[(__bridge id)kSecAttrModificationDate]);
    }
}

//查找数据
-(void)findData
{
    NSString *key = @"hello";
    NSString *server = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary *queryDict = @{
                                (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                                //(__bridge id)kSecAttrService:server,
                                //(__bridge id)kSecAttrAccount:key,
                                (__bridge id)kSecAttrGeneric:key,
                                (__bridge id)kSecReturnData:(__bridge id)kCFBooleanTrue,
                                (__bridge id)kSecAttrAccessGroup:@"AGD4F38NNV.com.dangsheng.test2",
                                (__bridge id)kSecMatchLimit : (__bridge id)kSecMatchLimitOne
                                /*当为kSecMatchLimit时，SecItemCopyMatching第二个参数为CFArrayRef，元素为CFDataRef*/
                                };
    CFDataRef dataRef = NULL;
    OSStatus state = SecItemCopyMatching((__bridge CFDictionaryRef)queryDict, (CFTypeRef*)&dataRef);
    if (state == errSecSuccess) {
        NSString *value = [[NSString alloc] initWithData:(__bridge_transfer NSData*)dataRef encoding:NSUTF8StringEncoding];
        NSLog(@"value:%@",value);
    }
    else
    {
        [self storeData];
    }
}

//查找数据
-(void)findDataItems
{
    NSString *key = @"hello";
    NSString *server = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary *queryDict = @{
                                (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                                //(__bridge id)kSecAttrService:server,
                                //(__bridge id)kSecAttrAccount:@"100",
                                (__bridge id)kSecAttrGeneric:key,
                                (__bridge id)kSecReturnData:(__bridge id)kCFBooleanTrue,
                                (__bridge id)kSecAttrAccessGroup:@"AGD4F38NNV.com.dangsheng.test2",
                                (__bridge id)kSecMatchLimit : (__bridge id)kSecMatchLimitAll
                                /*当为kSecMatchLimit时，SecItemCopyMatching第二个参数为CFArrayRef，元素为CFDataRef*/
                                };
    CFArrayRef arrayRef = NULL;
    OSStatus state = SecItemCopyMatching((__bridge CFDictionaryRef)queryDict, (CFTypeRef*)&arrayRef);
    if (state == errSecSuccess) {
        NSArray *arrays = CFBridgingRelease(arrayRef);
        for(NSUInteger i=0;i<[arrays count];++i)
        {
            CFDataRef dataRef = (__bridge CFDataRef)[arrays objectAtIndex:i];
            NSString *value = [[NSString alloc] initWithData:(__bridge_transfer NSData*)dataRef  encoding:NSUTF8StringEncoding];
            NSLog(@"value:%@",value);
        }
    }
    else
    {
        [self storeData];
    }
}

@end

