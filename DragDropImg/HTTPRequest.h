//
//  HTTPRequest.h
//  iFace
//
//  Created by Yin on 15-3-24.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTTPRequest;
@protocol RequestDelegate
@optional

- (void)sendProgress:(CGFloat)progress;
- (void)receiveProgress:(CGFloat)progress;
- (void)ws:(HTTPRequest *)iWS sendProgress:(CGFloat)progress;
- (void)ws:(HTTPRequest *)iWS receiveProgress:(CGFloat)progress;
- (void)wsOK:(HTTPRequest *)iWS;
- (void)wsFailed:(HTTPRequest *)iWS;

@end

@interface HTTPRequest : NSObject
{
    long long contentLength;
    NSMutableData *activeDownload;
}

@property (retain, nonatomic) NSMutableURLRequest *request;
@property (nonatomic) NSTimeInterval timeOut;//超时时间
@property (weak, nonatomic) id delegate;//代理
@property (retain, nonatomic) NSString *HTTPMethod;//请求类型(GET,POST)
@property (retain, nonatomic) NSString *host;//主服务器域名
@property (retain, nonatomic) NSString *hostPort;//端口
@property (retain, nonatomic) NSString *action;//根路径
@property (retain, nonatomic) NSString *dataType;//返回数据类型
@property (retain, nonatomic) NSString *urlString;
@property (retain, nonatomic) NSString *tag;
@property (retain, nonatomic) NSString *tagString;
@property (assign, nonatomic) NSInteger totalLength;
@property (assign, nonatomic) BOOL isShowErrmsg;//默认为YES,显示错误信息
@property (assign, nonatomic) BOOL isSaveXml;//是否保存返回数据为xml文件(默认为NO)

@property (retain, nonatomic) NSDictionary *dicTag;//标签
@property (retain, nonatomic,readonly) NSString *method;//接口名
@property (retain, nonatomic,readonly) NSDictionary *body;//接口名
@property (retain, nonatomic,readonly) NSData *responseData;//响应数据
@property (retain, nonatomic,readonly) NSString *responseString;//原解析响应数据
@property (retain, nonatomic,readonly) NSDictionary *jsonDic;//json解析
@property (retain, nonatomic,readonly) NSString *errMsg;//错误信息(解析)
@property (assign, nonatomic,readonly) NSInteger errType;//错误信息(服务器)

@property (retain, nonatomic,readonly) NSHTTPURLResponse *response;
@property (assign, nonatomic,readonly) int responseStatusCode;//请求响应码
@property (retain, nonatomic,readonly) NSString *responseStatusMessage;//请求响应信息

+ (NSString *)initUrl:(NSString *)method;
+ (HTTPRequest *)run:(NSString *)method body:(NSDictionary *)body delegate:(id)thedelegate;
+ (void)run:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* error)) handler NS_AVAILABLE(10_7, 5_0);
+ (id)requestWithDelegate:(id)delegate;
- (id)initWithDelegate:(id)delegate;
- (void)run:(NSString *)method body:(NSDictionary *)body delegate:(id)thedelegate;
- (void)run:(NSString *)method body:(NSDictionary *)body token:(NSString *)token;
- (void)run:(NSString *)method body:(NSDictionary *)body;
- (void)runWithUrl:(NSString *)urlStr body:(NSDictionary *)body;
- (void)setValue:(NSString *)value forHeader:(NSString *)field;
- (void)addValue:(NSString *)value forHeader:(NSString *)field;
- (void)start;
- (void)cancel;
- (NSDictionary *)dicWithHTTPBody;
- (void)run:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* error)) handler NS_AVAILABLE(10_7, 5_0);

@end

@interface MBPHudView : NSObject

- (void)hide:(BOOL)animated;

@end
