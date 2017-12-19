//
//  DownloadRequest.m
//  DragDropImg
//
//  Created by xy on 2017/12/14.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "DownloadRequest.h"
#import "MyHttpRequest.h"
#import "Tools.h"

@interface DownloadRequest ()<NSURLSessionDelegate>
{
    NSDate *receiveDate;
    NSMutableData *vData;
    int64_t currentLength;
}

@end

@implementation DownloadRequest

- (void)startRequest
{
    vData = [NSMutableData data];
    NSInteger appVer = 33;//当前APP内部版本号
    NSInteger hwVer = 2;//当前固件内部版本号
    NSString *hwName = @"ModelName";
    NSDictionary *body = @{@"deviceType":@(4),//4
                           @"appVer":@(appVer),
                           @"hwName":hwName,
                           @"hwVer":@(hwVer)};
    NSString *urlString = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V6.2.0.dmg";
//    urlString = @"http://120.25.226.186:32812/resources/videos/minion_01.mp4";
    //urlString = @"https://api.happyeasy.cc/api_V2/GetLastVersions";
    
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
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"backgroundIdentifier"];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 1;
    operationQueue.name = @"MyQueue";
    
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:operationQueue];
    
    _myDataTask = [_session downloadTaskWithRequest:request];
    
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

#pragma mark - --------NSURLSessionDelegate------------------------
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    //发送数据回调
    CGFloat rate = 1.0 * totalBytesSent / totalBytesExpectedToSend;
    NSLog(@"发送进度:%.2f%%,%lld",rate/0.01,task.countOfBytesSent);
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
    
    NSLog(@"收到服务器响应,内容长度：%lld",contentLength);
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSDictionary *info = @{@(NSURLSessionTaskStateRunning):@"Running",
                           @(NSURLSessionTaskStateSuspended):@"Suspended",
                           @(NSURLSessionTaskStateCanceling):@"Canceling",
                           @(NSURLSessionTaskStateCompleted):@"Completed"};
    [vData appendData:data];
    NSLog(@"已经收到数据,%@",info[@(dataTask.state)]);
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
    
    int64_t changeLength = totalBytesWritten - currentLength;
    currentLength = totalBytesWritten;
    dispatch_sync(dispatch_get_main_queue(), ^{
        /** 算出下载速度. */
        CGFloat kate = changeLength / space;
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
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    //任务完成
    dispatch_async(dispatch_get_main_queue(), ^{
        //[hudView hide:YES];
    });
    if (error) {
        /** 如果发生错误, 我们可以从error中获取到续传数据. */
        _resumData =  [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        
        NSLog(@"NSURLSessionTaskDelegate error: %@", error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self.view makeToast:error.localizedDescription];
        });
    } else {
        NSLog(@"NSURLSessionTaskStateCompleted 下载成功!");
        //[self.view makeToast:@"下载成功"];
    }
}

@end
