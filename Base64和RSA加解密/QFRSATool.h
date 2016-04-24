//
//  QFRSATool.h
//  
//
//  Created by xiating on 14-12-10.
//  Copyright (c) 2014年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QFRSATool : NSObject

/******************************************************************************
 函数名称 : +(NSString *)RSAEncrypt:(NSString *)plainTextString
 函数描述 : 使用公钥对字符串进行RSA加密
 输入参数 : (NSString *)plainTextString
 输出参数 : N/A
 返回参数 : (NSString *)
 备注信息 :
 ******************************************************************************/

+(NSString *)RSAEncrypt:(NSString *)plainTextString;
/******************************************************************************
 函数名称 : +(NSString *)RSADecryptString:(NSString *)rsaString
 函数描述 : 用私钥对已经进行RSA加密的字符串进行解密
 输入参数 : (NSString *)rsaString
 输出参数 : N/A
 返回参数 : (NSString *)
 备注信息 :
 ******************************************************************************/
+(NSString *)RSADecryptString:(NSString *)rsaString;

@end
