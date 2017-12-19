//
//  GetRequestToken.m
//  DragDropImg
//
//  Created by xy on 2017/12/15.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "GetRequestToken.h"
#import "EnumTypes.h"
#import "Tools.h"
#import "ExportGather.h"

@interface GetRequestToken ()<NSURLSessionDelegate>
{
    NSDate *receiveDate;
    NSMutableData *vData;
}

@property (nonatomic, retain) NSString *method;

@end

@implementation GetRequestToken

- (void)LoginIFace:(NSString *)mobile pwd:(NSString *)pwd
{
    NSString *salt = [Tools getRandomByLength:6];
    NSDictionary *body = @{@"areaCode":@"+86",
                           @"mobile":mobile,
                           @"password":pwd,
                           @"salt":salt,
                           @"deviceType":@(Device_iOS),
                           @"thirdPartyType":@(Login_iFace)};
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@",k_host,k_action,LoginIFace];
    _method = urlString.lastPathComponent;
    
    NSString *Account = [Tools objectForKey:@"Account"];
    if (![Account isEqualToString:mobile]) {
        [Tools setObject:mobile forKey:@"Account"];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    
    if ([NSJSONSerialization isValidJSONObject:body]) {
        //利用系统自带 JSON 工具封装 JSON 数据
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error: &error];
        request.HTTPMethod = @"POST";//设置为 POST
        request.HTTPBody = jsonData;//把刚才封装的 JSON 数据塞进去
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"text/json" forHTTPHeaderField:@"Content-Type"];
        //[request setValue:@(_totalLength).stringValue forHTTPHeaderField:@"Content-length"];
        if ([k_action isEqualToString:@"api_V2"]) {
            NSString *token = [body objectForKey:@"token"];
            if (token) {
                [request setValue:token forHTTPHeaderField:@"token"];
            }
            
            [request setValue:KIFaceApikey forHTTPHeaderField:@"apikey"];
            
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
            NSString *versions = [infoDict objectForKey:@"CFBundleShortVersionString"];
            [request setValue:versions forHTTPHeaderField:@"ver"];
        }
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 3;
    operationQueue.name = @"MyQueue";
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:operationQueue];
    
    // 由系统直接返回一个dataTask任务
    __weak typeof(self) wSelf = self;
    [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"数据类型, %@",response.MIMEType);
        [NSThread currentThread].name = @"MyThread";
        NSLog(@"%@",[NSThread currentThread]);
        if (data && !error) {
            // 网络访问成功
            [wSelf parseData:data response:response error:error];
        }
        else if (error) {
            // 网络访问失败
            NSLog(@"error, %@",error.localizedDescription);
        }else{
            // 网络访问失败
            NSLog(@"error, 请求异常");
        }
    }];
}

#pragma mark 解析数据
- (void)parseData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error
{
    NSString *MIMEType = response.MIMEType;
    if ([data length]>0 && ([MIMEType hasPrefix:@"text/"] || [MIMEType hasSuffix:@"/json"])) {
        NSDictionary *jsonDic = nil;
        if ([MIMEType hasSuffix:@"/json"]) {
            NSError *error = nil;
            jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error) {
                NSLog(@"%@",error.localizedDescription);
            }
            
            if (jsonDic) {
                NSLog(@"%@",[jsonDic customDescription]);
                return;
            }
        }
        NSString *textEncodingName = response.textEncodingName ?: @"utf-8";
        CFStringRef textEncode = (__bridge CFStringRef)textEncodingName;
        CFStringEncoding enc = CFStringConvertIANACharSetNameToEncoding(textEncode);
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (enc);
        NSString *stringL = [[NSString alloc] initWithData:data encoding: encoding];
        if (!stringL) {
            printf("/////////%s////////\n",response.textEncodingName.UTF8String);
            printf("自动获取编码失败\n");
            NSStringEncoding GBEncoding = NSUTF8StringEncoding;
            stringL = [[NSString alloc] initWithData:data encoding: GBEncoding];
            
            if (!stringL) {
                GBEncoding = 0x80000632;
                stringL = [[NSString alloc] initWithData:data encoding: GBEncoding];
            }
        }
        
        if ([stringL hasPrefix:@"\""] && [stringL hasSuffix:@"\""]) {
            stringL = [stringL substringWithRange:NSMakeRange(1, stringL.length-2)];
        }
        
        if (stringL) {
            //_responseString = stringL;
        }
        
        NSError *error1 = nil;
        NSData *data = [stringL dataUsingEncoding:NSUTF8StringEncoding];
        jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error1];
        if (jsonDic) {
            NSLog(@"%@",[jsonDic customDescription]);
            [jsonDic customDescription];
            if ([_method isEqualToString:LoginIFace]) {
                [self LoginIFaceSuccess:jsonDic];
            }
        }else{
            NSLog(@"%@",error1.localizedDescription);
            if (stringL) {
                NSLog(@"%@",stringL);
            }
        }
    }
    else if (data.length > 0) {
        NSLog(@"下载文件 类型:%@, 文件名:%@",MIMEType,response.suggestedFilename);
    }
}

- (void)LoginIFaceSuccess:(NSDictionary *)jsonDic
{
    NSString *token = [jsonDic stringForKey:@"msg"];//token
    NSDictionary *dicData = [jsonDic dictionaryForKey:@"data"];
    NSString *Mobile = [dicData stringForKey:@"Mobile"];
    int ThirdPartyType = [dicData intForKey:@"ThirdPartyType"];
    NSString *ThirdPartyID = [dicData stringForKey:@"ThirdPartyID"];
    NSString *ControlID = [dicData stringForKey:@"ControlID"];
    NSString *Salt = [dicData stringForKey:@"Salt"];
    
    NSDictionary *userInfo = @{@"mobile":Mobile?:@"",
                               @"token":token?:@"",
                               @"Salt":Salt?:@"",
                               @"ThirdPartyType":@(ThirdPartyType),
                               @"ThirdPartyID":ThirdPartyID?:@"",
                               @"ControlID":ControlID?:@""};
    [Tools setObject:userInfo forKey:@"userInfo"];
}

@end
