//
//  GetRequestToken.m
//  DragDropImg
//
//  Created by xy on 2017/12/15.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "GetRequestToken.h"
#import "HTTPRequest.h"
#import "ExportGather.h"
#import "EnumTypes.h"
#import "Tools.h"

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
    
    HTTPRequest *request = [HTTPRequest requestWithDelegate:self];
    [request run:urlString body:body];
    [request start];
    
    NSString *Account = [Tools objectForKey:@"Account"];
    if (![Account isEqualToString:mobile]) {
        [Tools setObject:mobile forKey:@"Account"];
    }
}

#pragma mark - --------WSDelegate----------------
- (void)wsOK:(HTTPRequest *)iWS
{
    NSDictionary *jsonDic = iWS.jsonDic;
    if ([iWS.method isEqualToString:LoginIFace]) {
        [self LoginIFaceSuccess:jsonDic];
    }
    else if ([iWS.method isEqualToString:GetLastVersions]) {
        NSLog(@"%@",[jsonDic customDescription]);
    }
}

- (void)wsFailed:(HTTPRequest *)iWS
{
    NSString *errMsg = iWS.errMsg;
    NSLog(@"%@,%d,%@",iWS.method,iWS.responseStatusCode,errMsg);
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
