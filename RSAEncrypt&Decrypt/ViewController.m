//
//  ViewController.m
//  RSAEncrypt&Decrypt
//
//  Created by 夏婷 on 16/4/24.
//  Copyright © 2016年 夏婷. All rights reserved.
//

#import "ViewController.h"
#import "QFRSATool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString * name = @"夏天";
    [self RSAEncrypt:name];
}
-(void)RSAEncrypt:(NSString *)string
{
    //进行了RSA加密并进行了Base64编码
    NSString *encodeStr = [QFRSATool RSAEncrypt:string];
    NSLog(@"RSA加密后---->\n%@",encodeStr);
    [self decriptStr:encodeStr];
}
-(void)decriptStr:(NSString *)encodeStr
{
    NSString *plainStr = [QFRSATool RSADecryptString:encodeStr];
    NSLog(@"RSA解密后数据:\n%@",plainStr);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
