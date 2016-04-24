//
//  QFRSATool.m
//  TPSApp
//
//  Created by xiating on 14-12-10.
//  Copyright (c) 2014年 YY. All rights reserved.
//

#import "QFRSATool.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation QFRSATool


#pragma mark - RSA 加密 用公钥加密
+(NSString *)RSAEncrypt:(NSString *)plainTextString
{
    if(!plainTextString || [plainTextString isEqualToString:@"null"]){
        return nil;
    }
    size_t cipherBufferSize = SecKeyGetBlockSize([self getPublicKey]);
    uint8_t *cipherBuffer = malloc(cipherBufferSize);
    uint8_t *nonce = (uint8_t *)[plainTextString UTF8String];
    SecKeyEncrypt([self getPublicKey], kSecPaddingNone, nonce, strlen( (char*)nonce ), &cipherBuffer[0], &cipherBufferSize);
    
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    //将加密后的数据进行Base64编码并转化为NSString
    return [encryptedData base64EncodedString];
}

#pragma mark - RSA 解密 用私钥解密
+ (NSData *)RSADecryptWithPrivateKey:(NSData *)cipherData {
    // 分配内存块，用于存放解密后的数据段
    size_t plainBufferSize = SecKeyGetBlockSize([QFRSATool getPrivateKey]);
    NSLog(@"plainBufferSize = %zd", plainBufferSize);
    uint8_t *plainBuffer = malloc(plainBufferSize * sizeof(uint8_t));
    // 计算数据段最大长度及数据段的个数
    double totalLength = [cipherData length];
    size_t blockSize = plainBufferSize;
    size_t blockCount = (size_t)ceil(totalLength / blockSize);
    NSMutableData *decryptedData = [NSMutableData data];
    // 分段解密
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        // 数据段的实际大小。最后一段可能比blockSize小。
        int dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        // 截取需要解密的数据段
        NSData *dataSegment = [cipherData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        OSStatus status = SecKeyDecrypt([QFRSATool getPrivateKey], kSecPaddingNone, (const uint8_t *)[dataSegment bytes], dataSegmentRealSize, plainBuffer, &plainBufferSize);
        if (status == errSecSuccess) {
            NSData *decryptedDataSegment = [[NSData alloc] initWithBytes:(const void *)plainBuffer length:plainBufferSize];
            [decryptedData appendData:decryptedDataSegment];
        } else {
            if (plainBuffer) {
                free(plainBuffer);
            }
            return nil;
        }
    }
    if (plainBuffer) {
        free(plainBuffer);
    }
    return decryptedData;
}
+(NSString *)RSADecryptString:(NSString *)rsaString
{
    //将已经进行base64编码的字符串解码成普通的NSData
    NSData *cipherData = [rsaString base64DecodedData];
    NSData *plainData = [QFRSATool RSADecryptWithPrivateKey:cipherData];
    return [[NSString alloc]initWithData:plainData encoding:NSUTF8StringEncoding];
}

#pragma mark - 获取加密公钥
+(SecKeyRef)getPublicKey{
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"rsacert" ofType:@"der"];
    NSData *certData = [NSData dataWithContentsOfFile:resourcePath];
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
    SecKeyRef key = NULL;
    SecTrustRef trust = NULL;
    SecPolicyRef policy = NULL;
    
    if (cert != NULL) {
        policy = SecPolicyCreateBasicX509();
        if (policy) {
            if (SecTrustCreateWithCertificates((CFTypeRef)cert, policy, &trust) == noErr) {
                SecTrustResultType result;
                if (SecTrustEvaluate(trust, &result) == noErr) {
                    key = SecTrustCopyPublicKey(trust);
                }
            }
        }
    }
    if (policy) CFRelease(policy);
    if (trust) CFRelease(trust);
    if (cert) CFRelease(cert);
    return key;
}

#pragma mark - 获取RSA 解密私钥
+(SecKeyRef)getPrivateKey
{
    SecIdentityRef identity;
    SecTrustRef trust;
    OSStatus status = -1;
    SecKeyRef _privateKey = nil;
    //创建密钥时输入的密码
    NSString *pkcsPassword = @"123456";
    //获取私钥路径
    NSString* pkcsPath = [[NSBundle mainBundle]pathForResource:@"p" ofType:@"p12"];
    
    NSData *p12Data = [NSData dataWithContentsOfFile:pkcsPath];
    if (p12Data) {
        CFStringRef password = (__bridge CFStringRef)pkcsPassword;
        const void *keys[] = {
            kSecImportExportPassphrase
        };
        const void *values[] = {
            password
        };
        CFDictionaryRef options = CFDictionaryCreate(kCFAllocatorDefault, keys, values, 1, NULL, NULL);
        CFArrayRef items = CFArrayCreate(kCFAllocatorDefault, NULL, 0, NULL);
        status = SecPKCS12Import((CFDataRef)p12Data, options, &items);
        if (status == errSecSuccess) {
            CFDictionaryRef identity_trust_dic = CFArrayGetValueAtIndex(items, 0);
            identity = (SecIdentityRef)CFDictionaryGetValue(identity_trust_dic, kSecImportItemIdentity);
            trust = (SecTrustRef)CFDictionaryGetValue(identity_trust_dic, kSecImportItemTrust);
            // certs数组中包含了所有的证书
            CFArrayRef certs = (CFArrayRef)CFDictionaryGetValue(identity_trust_dic, kSecImportItemCertChain);
            if ([(__bridge  NSArray *)certs count] && trust && identity) {
                // 如果没有下面一句，自签名证书的评估信任结果永远是kSecTrustResultRecoverableTrustFailure
                status = SecTrustSetAnchorCertificates(trust, certs);
                if (status == errSecSuccess) {
                    SecTrustResultType trustResultType;
                    // 通常, 返回的trust result type应为kSecTrustResultUnspecified，如果是，就可以说明签名证书是可信的
                    status = SecTrustEvaluate(trust, &trustResultType);
                    if ((trustResultType == kSecTrustResultUnspecified || trustResultType == kSecTrustResultProceed) && status == errSecSuccess) {
                        // 证书可信，可以提取私钥与公钥，然后可以使用公私钥进行加解密操作
                        status = SecIdentityCopyPrivateKey(identity, &_privateKey);
                        if (status == errSecSuccess && _privateKey) {
                            // 成功提取私钥
                        }
                    }
                }
            }
        }
        if (options) {
            CFRelease(options);
        }
    }
    return _privateKey;
}
@end
