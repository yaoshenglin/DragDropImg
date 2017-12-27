//
//  HTTPRequest.m
//  iFace
//
//  Created by Yin on 15-3-24.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import "HTTPRequest.h"
#import <AppKit/AppKit.h>
#import "GDataXMLNode.h"
#import "Tools.h"

NSString *const FileDownload = @"fileDownload";

@interface HTTPRequest ()<NSURLSessionDelegate>
{
    int64_t currentLen;
    NSDate *sendDate;//发送时间
    NSDate *receiveDate;//接收时间
    NSString *uploadFilePath;//上传文件路径
}

@end

@implementation HTTPRequest

@synthesize request;

+ (NSString *)initUrl:(NSString *)method
{
    method = method ?: @"";
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@",k_host,k_action,method];
    return urlString;
}

+ (id)requestWithDelegate:(id)delegate
{
    return [[HTTPRequest alloc] initWithDelegate:delegate];
}

- (instancetype)init
{
    if ((self = [super init])) {
        _timeOut = 30.0f;
        _isShowErrmsg = YES;
        _taskType = SessionTaskType_Data;
        activeDownload = [NSMutableData data];
        [self addObserver:self forKeyPath:@"request" options:0 context:nil];
    }
    
    return self;
}

- (id)initWithDelegate:(id)delegate
{
    if ((self = [super init])) {
        _timeOut = 30.0f;
        _isShowErrmsg = YES;
        _delegate = delegate;
        _taskType = SessionTaskType_Data;
        activeDownload = [NSMutableData data];
        [self addObserver:self forKeyPath:@"request" options:0 context:nil];
    }
    
    return self;
}

- (void)setMethod:(NSString *)method
{
    _method = method;
}

- (void)setJsonDic:(NSDictionary *)jsonDic
{
    _jsonDic = jsonDic;
}

- (void)setErrMsg:(NSString *)errMsg
{
    _errMsg = errMsg;
}

- (void)setTimeOut:(NSTimeInterval)timeOut
{
    _timeOut = timeOut;
    if (request) {
        request.timeoutInterval = _timeOut;
    }
}

- (void)setResponseStatusCode:(int)responseStatusCode
{
    _responseStatusCode = responseStatusCode;
}

- (void)setResponseStatusMessage:(NSString *)responseStatusMessage
{
    _responseStatusMessage = responseStatusMessage;
}

- (void)setHTTPMethod:(NSString *)HTTPMethod
{
    _HTTPMethod = HTTPMethod;
    request.HTTPMethod = HTTPMethod;//设置为 POST
}

#pragma mark - --------发送请求------------------------
- (void)run:(NSString *)method body:(NSDictionary *)body delegate:(id)thedelegate
{
    _delegate = thedelegate;
    [self run:method body:body];
}

- (void)run:(NSString *)method body:(NSDictionary *)body token:(NSString *)token
{
    [self run:method body:body];
    [self setValue:token forHeader:@"token"];
}

- (void)run:(NSString *)method body:(NSDictionary *)body
{
    NSString *urlString = [HTTPRequest initUrl:method];
    if (!_urlString) {
        _urlString = urlString;
        if ([method hasPrefix:@"http:"] || [method hasPrefix:@"https:"]) {
            _urlString = method;
        }
        
        NSRange range = [method rangeOfString:@"/"];
        if (range.location != NSNotFound) {
            NSArray *arr = [method componentsSeparatedByString:@"/"];
            _method = [arr firstObject];
        }else{
            _method = method;
        }
    }else{
        _method = method;
    }
    
    [self runWithUrl:_urlString body:body];
}

- (void)runWithUrl:(NSString *)urlStr body:(NSDictionary *)body
{
    NSError *error;
    _urlString = urlStr ?: _urlString;
    _method = _urlString.lastPathComponent;
    NSURL *url = [NSURL URLWithString:_urlString];
    //NSURLRequestUseProtocolCachePolicy
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_timeOut];//超时时间
    //request.userAgentString = [self makeUserAgentForRequest:nil];
    
    NSURLCache *urlCache = [NSURLCache sharedURLCache];
    /* 设置缓存的大小为0M*/
    [urlCache setMemoryCapacity:0];//1M = 1*1024*1024
    //从请求中获取缓存输出
    NSCachedURLResponse *response = [urlCache cachedResponseForRequest:request];
    //判断是否有缓存
    if (response != nil) {
        NSLog(@"如果有缓存输出，从缓存中获取数据");
        //[request setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
    }
    
    if (_taskType == SessionTaskType_Upload) {
        request.timeoutInterval = 180.0f;
        request.HTTPMethod = @"POST";//设置为 POST
        NSData *data = [self packageData:body];
        NSString *fileName;
        if (data) {
            fileName = [body objectForKey:@"fileName"];
        }
        //一连串上传头标签
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [self addValue:contentType forHeader: @"Content-Type"];
        NSMutableData *bodyData = [NSMutableData data];
        [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[NSData dataWithData:data]];
        [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:bodyData];
        [self setValue:@"application/json" forHeader:@"Accept"];
        body = nil;
    }
    else if (_taskType == SessionTaskType_Download) {
        request.HTTPMethod = @"GET";//设置为 GET
        NSString *languageCode = [Tools getLocaleLangArea][@"lang"];//en_CN,zh_CN(语言_地区)
        [request setValue:languageCode forHTTPHeaderField:@"lang"];
    }
    
    if ([NSJSONSerialization isValidJSONObject:body]) {
        //利用系统自带 JSON 工具封装 JSON 数据
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error: &error];
        request.HTTPMethod = @"POST";//设置为 POST
        request.HTTPBody = jsonData;//把刚才封装的 JSON 数据塞进去
        [self setValue:@"application/json" forHeader:@"Accept"];
        [self setValue:@"application/json" forHeader:@"Content-Type"];
        _body = [self dicWithHTTPBody];
        
        // 设置请求头文件
        //NSString *rangeValue = [NSString stringWithFormat:@"bytes=%d-", 1];
        //[self addValue:rangeValue forHeader:@"Range"];
    }
    
    if ([k_action isEqualToString:@"api_V2"]) {
        NSString *token = [body objectForKey:@"token"];
        token = token ?: [_dicTag objectForKey:@"token"];
        if (token) {
            [self setValue:token forHeader:@"token"];
        }
        
        [self setValue:KIFaceApikey forHeader:@"apikey"];
        
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *versions = [infoDict objectForKey:@"CFBundleShortVersionString"];
        [self setValue:versions forHeader:@"ver"];
    }
}

- (NSData *)packageData:(NSDictionary *)dic
{
    if (!dic) {
        return NULL;
    }
    
    NSData *data = nil;
    
    NSString *fileName = [dic objectForKey:@"fileName"];
    id file = [dic objectForKey:@"file"];
    //如果路径存在,直接拿取
    NSString *Path = dic[@"path"];
    if (Path) {
        uploadFilePath = Path;
    }
    
    if ([file isKindOfClass:[NSImage class]]) {
        NSImage *image = (NSImage *)file;
        NSString *ext = fileName.pathExtension;
        NSBitmapImageRep *rep = (NSBitmapImageRep *)image.representations.firstObject;
        int scale = rep.pixelsWide / image.size.width;//缩放值
        
        if (ext.length <= 0 && image) {
            ext = @"png";
            if (scale == 1) {
                fileName = [NSString stringWithFormat:@"%@.%@",fileName,ext];
            }
            else if (scale > 1) {
                NSString *scaleStr = [NSString stringWithFormat:@"@%dx",scale];
                if ([fileName hasSuffix:scaleStr]) {
                    fileName = [NSString stringWithFormat:@"%@.%@",fileName,ext];
                }else{
                    fileName = [NSString stringWithFormat:@"%@@%dx.%@",fileName,scale,ext];
                }
            }
            NSLog(@"%@",fileName);
        }
        else if (ext.length > 0 && image) {
            NSLog(@"%@",fileName);
        }else{
            fileName = nil;
            NSLog(@"文件不存在");
        }
        
        if (fileName.length > 0) {
            NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
            data = [NSData dataWithContentsOfFile:path];
            //[request addValue:path forHTTPHeaderField: @"path"];
        }
        
        //fileType = @"image/jpg";
        
        //如果路径存在,直接拿取
        if (Path) {
            data = [NSData dataWithContentsOfFile:Path];
        }
        
        if ([data length]>8000000) {
            NSLog(@"文件过大");
            return nil;
        }
    }
    else if ([file isKindOfClass:[NSData class]]) {
        data = file;
        //fileType = @"stream";
        if ([fileName hasSuffix:@".txt"]) {
            //fileType = @"text/plain";
        }
    }
    else if (!file && Path) {
        uploadFilePath = Path;
        data = [NSData dataWithContentsOfFile:Path];
    }
    
    return data;
}

//#pragma mark 生成User-Agent参数
//- (NSString *)makeUserAgentForRequest:(NSString *)deviceToken
//{
//    NSString *userAgent=nil;
//
//    NSBundle *bundle = [NSBundle mainBundle];
//
//    NSString *appName = @"vCaidan:";
//    NSString *appVersion = nil;
//    NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
//    if (marketingVersionNumber && developmentVersionNumber) {
//        if ([marketingVersionNumber isEqualToString:developmentVersionNumber]) {
//            appVersion = marketingVersionNumber;
//        } else {
//            appVersion = [NSString stringWithFormat:@"%@ ver:%@",marketingVersionNumber,developmentVersionNumber];
//        }
//    } else {
//        appVersion = (marketingVersionNumber ? marketingVersionNumber : developmentVersionNumber);
//    }
//
//    UIDevice *device = [UIDevice currentDevice];
//    NSString *deviceName = [device model];
//    NSString *OSName = [device systemName];
//    NSString *OSVersion = [device systemVersion];
//
//
//    userAgent = [NSString stringWithFormat:@"%@%@ deviceToken:%@ (%@; %@ %@)", appName, appVersion, deviceToken, deviceName, OSName, OSVersion];
//
//
//    return userAgent;
//}

- (void)setValue:(NSString *)value forHeader:(NSString *)field
{
    [request setValue:value forHTTPHeaderField:field];
}

- (void)setValue:(NSString *)value forHeader:(NSString *)field encoding:(NSStringEncoding)encoding
{
    if (encoding && value.length) {
        value = [value stringByAddingPercentEscapesUsingEncoding:encoding];
    }
    [request setValue:value forHTTPHeaderField:field];
}

- (void)addValue:(NSString *)value forHeader:(NSString *)field
{
    [request addValue:value forHTTPHeaderField:field];
}

- (void)start
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    //operationQueue.maxConcurrentOperationCount = 1;
    //operationQueue.name = @"MyQueue";
    
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    
    // 由系统直接返回一个dataTask任务

    switch (_taskType) {
        case SessionTaskType_Upload:
        {
            NSURL *fileURL = [NSURL URLWithString:uploadFilePath];
            if (fileURL) {
                _myDataTask = [_session uploadTaskWithRequest:request fromFile:fileURL];
            }else{
                _myDataTask = [_session uploadTaskWithRequest:request fromData:request.HTTPBody];
            }
        }
            break;
        case SessionTaskType_Download:
            _myDataTask = [_session dataTaskWithRequest:request];
            break;
            
        default:
            _myDataTask = [_session dataTaskWithRequest:request];
            break;
    }
    
    [self resume];
}

- (void)resume
{
    [_myDataTask resume];//继续
}

- (void)suspend
{
    [_myDataTask suspend];//暂停
}

- (void)cancel
{
    [_session invalidateAndCancel];//取消
}

- (NSDictionary *)dicWithHTTPBody
{
    NSError *error = nil;
    NSDictionary *allHTTPHeaderFields = request.allHTTPHeaderFields;
    NSString *ContentType = [allHTTPHeaderFields objectForKey:@"Content-Type"];
    if ([ContentType containsString:@"multipart/form-data"]) {
        return @{@"type":@"file"};
    }
    NSDictionary *body = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"获取body失败,%@",error.localizedDescription);
    }
    return body;
}

#pragma mark - --------请求回调------------------------
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    //发送数据回调
    CGFloat totalData = totalBytesExpectedToSend * 1.0;
    CGFloat rate = totalBytesSent / totalData;
    NSTimeInterval space = [[NSDate date] timeIntervalSinceDate:sendDate];
    if (space < 0.1 && rate != 1) {
        //NSString *msg = @"----------发送进度没有更新--------------------";
        //[self.class printDebugMsg:msg];
        return;
    }
    
    sendDate = [NSDate date];
    if ([_delegate respondsToSelector:@selector(ws:sendProgress:)]) {
        [_delegate ws:self sendProgress:rate];
    }
    else if ([_delegate respondsToSelector:@selector(sendProgress:)]) {
        [_delegate sendProgress:rate];
    }
    
    NSLog(@"发送进度:%.2f%%,%lld",rate/0.01,task.countOfBytesSent);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    //收到服务器响应回调
    _response = (NSHTTPURLResponse *)response;
    NSDictionary *userInfo = _response.allHeaderFields;
    _responseStatusCode = (int)_response.statusCode;
    contentLength = [userInfo[@"Content-Length"] longLongValue];
    _dataType = response.MIMEType;
    //NSLog(@"File Size:%lld",contentLength);
    if (_responseStatusCode != 200) {
        NSLog(@"响应错误,%@,%d",_method,_responseStatusCode);
    }
    
    if (!_body) {
    }
    
    NSLog(@"收到服务器响应,内容长度：%lld",contentLength);
    
    completionHandler(NSURLSessionResponseAllow);
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
//{
//    //告诉代理人下载任务已经恢复
//    NSLog(@"NSURLSessionDownloadDelegate 下载任务已经恢复");
//}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    //NSDictionary *info = @{@(NSURLSessionTaskStateRunning):@"Running",
    //                       @(NSURLSessionTaskStateSuspended):@"Suspended",
    //                       @(NSURLSessionTaskStateCanceling):@"Canceling",
    //                       @(NSURLSessionTaskStateCompleted):@"Completed"};
    //NSLog(@"已经收到数据,%@",info[@(dataTask.state)]);
    [activeDownload appendData:data];
    if (_responseStatusCode != 200) {
        NSLog(@"请求有误");
        return;
    }
    
    CGFloat totalLen = contentLength * 1.0;
    CGFloat rate = activeDownload.length / totalLen;
    NSTimeInterval space = [[NSDate date] timeIntervalSinceDate:receiveDate];
    if (space < 0.02 && rate != 1) {
        //NSString *msg = @"----------接收进度没有更新--------------------";
        //[self.class printDebugMsg:msg];
        return;
    }
    
    //CGFloat NetSpeed = (activeDownload.length-currentLen)/space;
    currentLen = activeDownload.length;
    receiveDate = [NSDate date];
    if ([_delegate respondsToSelector:@selector(ws:receiveProgress:)]) {
        [_delegate ws:self receiveProgress:rate];
    }
    else if ([_delegate respondsToSelector:@selector(receiveProgress:)]) {
        [_delegate receiveProgress:rate];
    }
    
    NSLog(@"接收进度:%.2f%%",rate/0.01);
}

//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location;
//{
//
//}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    //任务完成
    if (error) {
        /** 如果发生错误, 我们可以从error中获取到续传数据. */
        NSDictionary *userInfo = error.userInfo;
        _resumData =  [userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        
        NSLog(@"请求失败, %d, %@, %@",_responseStatusCode,_method,error.localizedDescription);
        //NSString *path = [[NSBundle mainBundle] pathForResource:@"errDic" ofType:@"txt"];
        //NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
        //NSLog(@"%@",dic[@(error.code).stringValue]);
        _errMsg = error.localizedDescription;
        if ([_errMsg hasSuffix:@"。"]) {
            _errMsg = [_errMsg substringToIndex:_errMsg.length-1];
        }
        _urlString = userInfo[@"NSErrorFailingURLStringKey"];
        [self wsFailedWithDelegate:_delegate];
    } else {
        NSLog(@"NSURLSessionTaskStateCompleted 操作成功!,%ld",activeDownload.length);
        //请求完成
        _responseData = activeDownload;
        if (_responseStatusCode != 200) {
            //请求失败
            [self parseData:activeDownload];
        }else{
            if ([_dataType hasPrefix:@"text/"]||[_dataType hasSuffix:@"/json"]) {
                //解析成字符
                [self parseData:activeDownload];
            }else{
                //文件
                _method = FileDownload;
                if ([_delegate respondsToSelector:@selector(wsOK:)]) {
                    [_delegate wsOK:self];
                }
            }
        }
    }
}

#pragma mark 解析数据
- (void)parseData:(NSData *)data
{
    if ([data length]>0) {
        NSString *textEncodingName = _response.textEncodingName ?: @"gb2312";
        CFStringRef textEncode = (__bridge CFStringRef)textEncodingName;
        CFStringEncoding enc = CFStringConvertIANACharSetNameToEncoding(textEncode);
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (enc);
        NSString *stringL = [[NSString alloc] initWithData:activeDownload encoding: encoding];
        if (!stringL) {
            if (![textEncodingName isEqualToString:@"utf-8"]) {
                encoding = NSUTF8StringEncoding;
                printf("/////////%s////////\n",textEncodingName.UTF8String);
                stringL = [[NSString alloc] initWithData:activeDownload encoding: encoding];
            }
            
            if (!stringL) {
                encoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                stringL = [[NSString alloc] initWithData:activeDownload encoding: encoding];
            }
        }
        
        if ([stringL hasPrefix:@"\""] && [stringL hasSuffix:@"\""]) {
            stringL = [stringL substringWithRange:NSMakeRange(1, stringL.length-2)];
        }
        
        if (stringL) {
            _responseString = stringL;
        }
        
        NSError *error1 = nil;
        NSData *data = [stringL dataUsingEncoding:NSUTF8StringEncoding];
        if (data.length <= 0) {
            //文件
            _method = FileDownload;
            if ([_delegate respondsToSelector:@selector(wsOK:)]) {
                [_delegate wsOK:self];
            }
            return;
        }
        
        if ([_dataType hasSuffix:@"/json"]) {
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error1];
            //NSLog(@"%@",resultsDictionary);
            
            BOOL isSuccess = [[jsonDic objectForKey:@"flag"] boolValue];
            if (isSuccess && !error1) {
                _jsonDic = jsonDic;
                if ([_delegate respondsToSelector:@selector(wsOK:)]) {
                    @try {
                        [_delegate wsOK:self];
                    }
                    @catch (NSException *ex) {
                        NSString *result = [NSString stringWithFormat:@"RequestOK,%@,%@,%@",_method,ex.name,ex.reason];
                        _errMsg = @"解析错误";//解析错误
                        NSLog(@"%@",result);
                        [self wsFailedWithDelegate:_delegate];
                        
                        NSString *path = [@"~/Documents/HttpException.txt" stringByExpandingTildeInPath];
                        [self.class writeToEndOfFileAtPaths:path content:result];
                    }
                    @finally {
                    }
                }
            }
            else if (jsonDic) {
                NSString *msg = [jsonDic objectForKey:@"msg"];
                msg = (msg && [msg isKindOfClass:[NSString class]]) ? msg : @"请求错误";//请求错误
                _jsonDic = jsonDic;
                _errMsg = msg;
                [self wsFailedWithDelegate:_delegate];
            }
        }else{
            NSString *msg = nil;
            msg = [GDataXMLNode getBody:stringL];
            msg = msg.length ? msg : @"服务暂时不可用";//服务暂时不可用
            _errMsg = msg;
            [self wsFailedWithDelegate:_delegate];
        }
        
    }
}

- (void)wsFailedWithDelegate:(id)delegate
{
    if ([delegate respondsToSelector:@selector(wsFailed:)]) {
        @try {
            if (!_isShowErrmsg) {
                NSLog(@"%@,%@",_method,_errMsg);
                //_errMsg = nil;
            }
            else if (_responseStatusCode == 500) {
                _errMsg = @"无法连接到服务器,请稍候再试";
            }
            
            _errType = [[_jsonDic objectForKey:@"type"] integerValue];
            [delegate wsFailed:self];
        }
        @catch (NSException *exception) {
            NSLog(@"RequestFailed,%@,%@,%@",_method,exception.name,exception.reason);
        }
        @finally {
        }
    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"request"];
}

#pragma mark - -------HTTPRequest--------------------
#pragma mark 创建请求体
- (void)run:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler
{
    if ([NSJSONSerialization isValidJSONObject:body])//判断是否有效
    {
        NSError* error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error: &error];//利用系统自带 JSON 工具封装 JSON 数据
        NSString *urlString = [HTTPRequest initUrl:method];;
        _urlString = _urlString ?: urlString;
        if ([method hasPrefix:@"http:"]) {
            _urlString = method;
        }
        NSURL* url = [NSURL URLWithString:_urlString];
        request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_timeOut];
        [request setHTTPMethod:@"POST"];//设置为 POST
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)[jsonData length]] forHTTPHeaderField:@"Content-length"];
        [request setTimeoutInterval:_timeOut];
        [request setHTTPBody:jsonData];//把刚才封装的 JSON 数据塞进去
        
        /*
         *发起异步访问网络操作 并用 block 操作回调函数
         */
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[[NSOperationQueue alloc] init]];
        _myDataTask = [_session dataTaskWithRequest:request completionHandler:completionHandler];
        [_myDataTask resume];
    }else{
        NSString *urlString = [HTTPRequest initUrl:method];;
        _urlString = _urlString ?: urlString;
        if ([method hasPrefix:@"http:"]) {
            _urlString = method;
        }
        NSURL* url = [NSURL URLWithString:_urlString];
        request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_timeOut];
        [request setHTTPMethod:@"GET"];//设置为 POST
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        /*
         *发起异步访问网络操作 并用 block 操作回调函数
         */
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[[NSOperationQueue alloc] init]];
        _myDataTask = [_session dataTaskWithRequest:request completionHandler:completionHandler];
        [_myDataTask resume];
    }
}

+ (HTTPRequest *)run:(NSString *)method body:(NSDictionary *)body delegate:(id)thedelegate
{
    HTTPRequest *result = [HTTPRequest requestWithDelegate:thedelegate];
    [result run:method body:body];
    [result start];
    
    return result;
}

+ (void)run:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler
{
    HTTPRequest *result = [[HTTPRequest alloc] init];
    [result run:method body:body completionHandler:completionHandler];
}

#pragma mark 打印调试信息
+ (void)printDebugMsg:(NSString *)msg
{
#if DEBUG
    NSLog(@"%@",msg);
#endif
}

//写入文件结尾
+ (void)writeToEndOfFileAtPaths:(NSString *)path content:(NSString *)content
{
    BOOL isExit = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    if (!isExit) {
        
        NSLog(@"文件不存在");
        NSString *s = @"解析结果异常";
        [s writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
    }
    
    NSFileHandle  *outFile;
    NSData *buffer;
    
    outFile = [NSFileHandle fileHandleForWritingAtPath:path];
    
    if(outFile == nil)
    {
        NSLog(@"Open of file for writing failed");
    }
    
    //找到并定位到outFile的末尾位置(在此后追加文件)
    [outFile seekToEndOfFile];
    
    //读取inFile并且将其内容写到outFile中
    NSDateFormatter *data_time = [[NSDateFormatter alloc]init];
    [data_time setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeStr = [data_time stringFromDate:[NSDate date]];
    NSString *bs = [NSString stringWithFormat:@"\n\n%@\n%@",timeStr,content];
    buffer = [bs dataUsingEncoding:NSUTF8StringEncoding];
    
    [outFile writeData:buffer];
    
    //关闭读写文件
    [outFile closeFile];
}

@end
