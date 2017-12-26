//
//  UploadRequest.m
//  DragDropImg
//
//  Created by xy on 2017/12/15.
//  Copyright © 2017年 xy. All rights reserved.
//

#define BOUNDRY_B @"cc013nchft7" //分隔符标志
#define ENTER @"\r\n"  //回车换行

#import "UploadRequest.h"
#import "ExportGather.h"
#import "EnumTypes.h"
#import "Tools.h"
//#import "GDataXMLNode.h"

@interface UploadRequest ()<NSURLSessionDelegate,NSStreamDelegate>
{
    NSDate *receiveDate;
    NSMutableData *vData;
}

@end

@implementation UploadRequest

- (NSMutableURLRequest *)withUrl:(NSString *)urlString body:(NSDictionary *)body
{
    //urlString = @"http://www.freeimagehosting.net/upl.php";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    request.timeoutInterval = 180;
    NSString *fileName = [body objectForKey:@"fileName"];
    
    id file = [body objectForKey:@"file"];
    NSData *data = nil;
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
            [request addValue:path forHTTPHeaderField: @"path"];
        }
    }
    else if ([file isKindOfClass:[NSData class]]) {
        data = file;
    }
    
    //一连串上传头标签
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    request.HTTPMethod = @"POST";//设置为 POST
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *bodyData = [NSMutableData data];
    [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[NSData dataWithData:data]];
    [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:bodyData];
    
    //计算数据长度
    NSInteger totalLength = bodyData.length;
    [request setValue:@(totalLength).stringValue forHTTPHeaderField:@"Content-length"];
    
    return request;
}

- (void)startRequest
{
    vData = [NSMutableData data];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@",k_host,k_action,UpdateFace];
//    urlString = @"http://www.freeimagehosting.net/upl.php";
    NSString *imgName = @"msg2";
    NSImage *image = [NSImage imageNamed:imgName];
    
    NSDictionary *body = @{@"file":image,@"fileName":imgName};
    
    NSMutableURLRequest *request = [self withUrl:urlString body:body];
    NSDictionary *userInfo = [Tools objectForKey:@"userInfo"];
    NSString *token = [userInfo stringForKey:@"token"];
    [request addValue:token forHTTPHeaderField:@"token"];
    [request addValue:@(692).stringValue forHTTPHeaderField:@"SceneID"];
    
    __unused NSString *path = [request.allHTTPHeaderFields objectForKey:@"path"];
    [request setValue:nil forHTTPHeaderField:@"path"];

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 1;
    operationQueue.name = @"MyQueue";
    
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    _myDataTask = [_session uploadTaskWithRequest:request fromData:request.HTTPBody];
//    _myDataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (data) {
//            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//            if (dictionary) {
//                NSLog(@"%@",dictionary);
//            }
//            else if (error) {
//                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                NSLog(@"%@",string);
//            }
//        }
//        else if (error) {
//            NSLog(@"%@",error.localizedDescription);
//        }
//    }];
    
    // 每一个任务默认都是挂起的，需要调用 resume 方法
    [_myDataTask resume];
}

- (void)stopRequest
{
    [_myDataTask suspend];
}

- (void)cancel
{
    [_session invalidateAndCancel];
}

#pragma mark - --------NSURLSessionDataDelegate------------------------
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    //发送数据回调
    CGFloat rate = 1.0 * totalBytesSent / totalBytesExpectedToSend;
    NSLog(@"发送进度:%.2f%%,%lld",rate/0.01,task.countOfBytesSent);
}

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
            
            [Tools alertWithMessage:@"创建文件夹失败" informative:error.localizedDescription completionHandler:^(NSModalResponse returnCode, NSString *title) {
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
    NSLog(@"接收进度:%.2f,%lld",rate/0.01,downloadTask.countOfBytesReceived);
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
        NSLog(@"NSURLSessionTaskStateCompleted 操作成功!");
        //[self.view makeToast:@"下载成功"];
        if (vData.length > 0) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:vData options:kNilOptions error:&error];
            if (dictionary) {
                NSLog(@"%@",[dictionary customDescription]);
            }
            else if (error) {
                NSString *string = [[NSString alloc] initWithData:vData encoding:NSUTF8StringEncoding];
                //string = [GDataXMLNode getBody:string];
                NSLog(@"%@",string);
            }
        }
        else if (error) {
            NSLog(@"%@",error.localizedDescription);
        }
    }
}

@end
