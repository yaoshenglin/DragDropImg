//
//  DataRequest.m
//  DragDropImg
//
//  Created by xy on 2017/12/14.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "DataRequest.h"
#import "MyHttpRequest.h"
#import "Tools.h"

@interface DataRequest ()<NSURLSessionDelegate>
{
    NSDate *receiveDate;
    NSMutableData *vData;
}

@end

@implementation DataRequest

- (void)startRequest
{
    NSInteger appVer = 33;//当前APP内部版本号
    NSInteger hwVer = 2;//当前固件内部版本号
    NSString *hwName = @"ModelName";
    NSDictionary *body = @{@"deviceType":@(4),//4
                           @"appVer":@(appVer),
                           @"hwName":hwName,
                           @"hwVer":@(hwVer)};
    NSString *urlString = @"http://dldir1.qq.com/qqfile/qq/QQ2013/QQ2013SP5/9050/QQ2013SP5.exe";
    urlString = @"http://120.25.226.186:32812/resources/videos/minion_01.mp4";
    urlString = @"https://api.happyeasy.cc/api_V2/GetLastVersions";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    
    if ([NSJSONSerialization isValidJSONObject:body]) {
        //利用系统自带 JSON 工具封装 JSON 数据
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error: &error];
        _totalLength = jsonData.length;
        request.HTTPMethod = @"POST";//设置为 POST
        request.HTTPBody = jsonData;//把刚才封装的 JSON 数据塞进去
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@(_totalLength).stringValue forHTTPHeaderField:@"Content-length"];
        if ([k_action isEqualToString:@"api_V2"]) {
            NSString *token = [body objectForKey:@"token"];
            if (token) {
                [request setValue:token forHTTPHeaderField:@"token"];
            }
            
            //[self setValue:KIFaceApikey forHeader:@"apikey"];
            
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
            NSString *versions = [infoDict objectForKey:@"CFBundleShortVersionString"];
            [request setValue:versions forHTTPHeaderField:@"ver"];
        }
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 1;
    operationQueue.name = @"MyQueue";
    
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:operationQueue];
    //[self.session downloadTaskWithResumeData:_resumData];
    
    // 由系统直接返回一个dataTask任务
    __weak typeof(self) wSelf = self;
    _myDataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 网络请求完成之后就会执行，NSURLSession自动实现多线程
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            [NSThread sleepForTimeInterval:0.3];
            dispatch_async(dispatch_get_main_queue(), ^{
                //hudView.progress = 1;
                //[hudView hide:YES afterDelay:0.2];
            });
        });
        
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
    
//    _myDataTask = [_session dataTaskWithRequest:request];
    //_myDataTask = [_session downloadTaskWithRequest:request];
    
    // 每一个任务默认都是挂起的，需要调用 resume 方法
    [self resume];
}

- (void)resume
{
    [_myDataTask resume];
}

- (void)suspend
{
    [_myDataTask suspend];
}

- (void)cancel
{
    [_session invalidateAndCancel];
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
        }else{
            NSLog(@"%@",error1.localizedDescription);
        }
    }
    else if (data.length > 0) {
        NSLog(@"下载文件 类型:%@, 文件名:%@",MIMEType,response.suggestedFilename);
    }
}

#pragma mark - --------NSURLSessionDelegate------------------------
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error
{
    NSLog(@"NSURLSessionDelegate,%@,%@",session,error.localizedDescription);
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    NSLog(@"NSURLSessionDelegate,%@,%@",session,challenge);
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"NSURLSessionDelegate,%@",session);
}

#pragma mark - --------NSURLSessionDataDelegate------------------------
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    //收到服务器响应回调
    NSHTTPURLResponse *_response = (NSHTTPURLResponse *)response;
    NSDictionary *userInfo = _response.allHeaderFields;
    int responseStatusCode = (int)_response.statusCode;
    int64_t contentLength = [userInfo[@"Content-Length"] longLongValue];
    //NSLog(@"File Size:%lld",contentLength);
    if (responseStatusCode != 200) {
        NSLog(@"响应错误,%d",responseStatusCode);
    }
    
    NSLog(@"%lld",contentLength);
}

#pragma mark - --------NSURLSessionDownloadDelegate------------------------
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location;
{
    _totalLength = downloadTask.response.expectedContentLength;
    NSLog(@"下载完成,%ld",(long)_totalLength);
    
    /** 取出Library文件的路径. */
    NSString *saveString = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    saveString = [[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent];
    
    /** 取出"55fbb97f13aa9.mp4" 字符串. */
    NSString *fileName = downloadTask.response.suggestedFilename;
    /** 拼接成保存路径. */
    saveString = [saveString stringByAppendingPathComponent:@"Downloads"];
    NSString *saveURL = [saveString stringByAppendingPathComponent:fileName];
    
    /** 将下载好的数据复制到波哦村路径, 避免丢失. */
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:saveString]) {
        [fileManager createDirectoryAtPath:saveString withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"%@",error.localizedDescription);
            
            [Tools alertWithMessage:@"创建文件夹失败" informative:error.localizedDescription completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSAlertFirstButtonReturn) {
                    //响应第一个按钮被按下
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                        });
                        dispatch_sync(dispatch_get_main_queue(), ^{
                        });
                    });
                }
            }];
        }
    }
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:saveURL]];
    if (data.length != _totalLength) {
        NSLog(@"新文件,%ld",(long)data.length);
        if ([fileManager fileExistsAtPath:saveString]) {
            [fileManager copyItemAtURL:location toURL:[NSURL fileURLWithPath:saveURL] error:&error];
        }
    }
}

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    CGFloat rate = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
    NSTimeInterval space = [[NSDate date] timeIntervalSinceDate:receiveDate];
    
    if (space < 0.1 && rate != 1) {
        //NSString *msg = @"----------接收进度没有更新--------------------";
        //[self.class printDebugMsg:msg];
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        /** 算出下载速度. */
        CGFloat kate = bytesWritten / space;
        //hudView.labelText = speedString;
        if ([_delegate respondsToSelector:@selector(downloadToProgress:rate:)]) {
            [_delegate downloadToProgress:rate rate:kate];
        }
    });
    
    receiveDate = [NSDate date];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //hudView.progress = rate;
    });
    //NSLog(@"接收进度:%.2f,%lld",rate/0.01,downloadTask.countOfBytesReceived);
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    //告诉代理人下载任务已经恢复
    NSLog(@"NSURLSessionDownloadDelegate 下载任务已经恢复");
}

#pragma mark - --------NSURLSessionTaskDelegate------------------------
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    //收到服务器响应回调
    NSHTTPURLResponse *_response = (NSHTTPURLResponse *)task.response;
    if (!_response) {
        return;
    }
    
    NSDictionary *userInfo = _response.allHeaderFields;
    int responseStatusCode = (int)_response.statusCode;
    int64_t contentLength = [userInfo[@"Content-Length"] longLongValue];
    //NSLog(@"File Size:%lld",contentLength);
    if (responseStatusCode != 200) {
        NSLog(@"响应错误,%d",responseStatusCode);
    }
    
    NSLog(@"%lld",contentLength);
    
    CGFloat rate = 1.0 * totalBytesSent / totalBytesExpectedToSend;
    NSLog(@"发送进度:%.2f,%lld",rate/0.01,task.countOfBytesReceived);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    //任务完成
    dispatch_async(dispatch_get_main_queue(), ^{
        //[hudView hide:YES];
    });
    if (error) {
        NSLog(@"NSURLSessionTaskDelegate error: %@", error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self.view makeToast:error.localizedDescription];
        });
    } else {
        NSLog(@"NSURLSessionTaskStateCompleted 下载成功!");
        //[self.view makeToast:@"下载成功"];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    NSLog(@"NSURLSessionTaskDelegate %s",__func__);
}

/* The task has received a request specific authentication challenge.
 * If this delegate is not implemented, the session specific authentication challenge
 * will *NOT* be called and the behavior will be the same as using the default handling
 * disposition.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    NSLog(@"NSURLSessionTaskDelegate %s",__func__);
}

/* Sent if a task requires a new, unopened body stream.  This may be
 * necessary when authentication has failed for any request that
 * involves a body stream.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream * _Nullable bodyStream))completionHandler
{
    NSLog(@"NSURLSessionTaskDelegate %s",__func__);
}

/*
 * Sent when complete statistics information has been collected for the task.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics
{
    NSLog(@"NSURLSessionTaskDelegate %s",__func__);
}

@end
