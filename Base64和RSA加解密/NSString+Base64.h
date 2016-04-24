//
//  NSString+Base64.h
//
//  Version 1.0.2
//
//  Created by Nick Lockwood on 12/01/2012.
//  Copyright (C) 2012 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/Base64
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64)
//用已进行base64编码的字符串创建字符串
+ (NSString *)stringWithBase64EncodedString:(NSString *)string;
//将字符串进行base64编码
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
//将字符串进行base64编码
- (NSString *)base64EncodedString;
//将已进行base64编码的字符串解码并返回字符串
- (NSString *)base64DecodedString;

//将已进行base64编码的字符串解码并转为NSData
- (NSData *)base64DecodedData;

@end