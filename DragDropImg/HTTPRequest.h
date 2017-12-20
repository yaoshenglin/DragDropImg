//
//  HTTPRequest.h
//  iFace
//
//  Created by Yin on 15-3-24.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, SessionTaskType) {
    SessionTaskType_Data        = 0,    //普通
    SessionTaskType_Upload      = 1,    //上传
    SessionTaskType_Download    = 2,    //下载
};

FOUNDATION_EXPORT NSString *const FileDownload;//文件下载

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

@property (nonatomic, weak) id delegate;//代理
@property (nonatomic, assign) SessionTaskType taskType;
@property (nonatomic, strong) NSData *resumData; // 续传数据
@property (nonatomic, strong) NSURLSession *session; // 会话
@property (nonatomic, strong) NSURLSessionTask *myDataTask; // 请求任务
@property (nonatomic, retain) NSMutableURLRequest *request;
@property (nonatomic) NSTimeInterval timeOut;//超时时间
@property (nonatomic, retain) NSString *HTTPMethod;//请求类型(GET,POST)
@property (nonatomic, retain) NSString *host;//主服务器域名
@property (nonatomic, retain) NSString *hostPort;//端口
@property (nonatomic, retain) NSString *action;//根路径
@property (nonatomic, retain) NSString *dataType;//返回数据类型
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain) NSString *tagString;
@property (nonatomic, assign) NSInteger totalLength;
@property (nonatomic, assign) BOOL isShowErrmsg;//默认为YES,显示错误信息
@property (nonatomic, assign) BOOL isSaveXml;//是否保存返回数据为xml文件(默认为NO)

@property (nonatomic, retain) NSDictionary *dicTag;//标签
@property (nonatomic, retain,readonly) NSString *method;//接口名
@property (nonatomic, retain,readonly) NSDictionary *body;//接口名
@property (nonatomic, retain,readonly) NSData *responseData;//响应数据
@property (nonatomic, retain,readonly) NSString *responseString;//原解析响应数据
@property (nonatomic, retain,readonly) NSDictionary *jsonDic;//json解析
@property (nonatomic, retain,readonly) NSString *errMsg;//错误信息(解析)
@property (nonatomic, assign,readonly) NSInteger errType;//错误信息(服务器)

@property (nonatomic, retain,readonly) NSHTTPURLResponse *response;
@property (nonatomic, assign,readonly) int responseStatusCode;//请求响应码
@property (nonatomic, retain,readonly) NSString *responseStatusMessage;//请求响应信息

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
- (void)setValue:(NSString *)value forHeader:(NSString *)field encoding:(NSStringEncoding)encoding;
- (void)addValue:(NSString *)value forHeader:(NSString *)field;
- (void)start;//启动
- (void)resume;//继续
- (void)suspend;//暂停
- (void)cancel;//取消
- (NSDictionary *)dicWithHTTPBody;
- (void)run:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* error)) handler NS_AVAILABLE(10_7, 5_0);

@end

@interface MBPHudView : NSObject

- (void)hide:(BOOL)animated;

@end
