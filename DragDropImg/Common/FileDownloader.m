//
//  IconDownload.m
//  iCaidan
//
//  Created by jxyxhama on 11-11-27.
//  Copyright 2011年 彩旦科技. All rights reserved.
//

#import "FileDownloader.h"
#import "Tools.h"
#import "GDataXMLNode.h"

@interface FileDownloader ()<NSURLSessionDelegate>

@end

@implementation FileDownloader

@synthesize fileName;
@synthesize timeOut;
@synthesize isAutoSave;
@synthesize isShowActivity;
//@synthesize Type;
@synthesize hostPort;
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
//        Type = ActivityStyle_WhiteLarge;
        fileName = @"";
        isAutoSave = YES;
    }
    
    return self;
}

#pragma ***********************************************************************************************
#pragma mark 下载文件, 文件链接为:http://url/fileName
- (void)setData:(NSDictionary *)dicData delegate:(id)delegate
{
    //dicData = @{@"view":@"",@"url":@"",@"name":@""};
    NSImageView *imgView = dicData[@"view"];
    NSString *fileUrl = dicData[@"url"];
    NSString *name = dicData[@"name"];
    
    if (name.length <= 0 || fileUrl.length <= 0) {
        return;
    }
    
    [self setImg:imgView fileUrl:fileUrl fileName:name delegate:self];
}

- (void)setImg:(NSImageView *)imgView fileUrl:(NSString *)fileUrl fileName:(NSString *)theFileName delegate:(id<FileDownloaderDelegate>)theDelegate
{
    if (!theFileName) {
        
        [delegate downLoadFail:self];
        return;
    }
    
    delegate = theDelegate;
    _imgView = imgView;
    [self downWithUrl:fileUrl fileName:theFileName];
}

- (void)downWithUrl:(NSString *)fileUrl fileName:(NSString *)theFileName
{
    fileName = theFileName;
    
    NSString *urlString;
    
    if ([fileUrl hasPrefix:@"http"]) {
        urlString = fileUrl;
    }
    else {
        NSString *host = k_res_host;
        //urlString = [NSString stringWithFormat:@"%@%@", host, fileUrl];
        urlString = [host stringByAppendingPathComponent:fileUrl];
    }
    
    self.urlString = urlString;
    activeDownload = [NSMutableData data];
    NSURL *url = [NSURL URLWithString:urlString];
    timeOut = timeOut==0 ? 60 : timeOut;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeOut];//超时时间
    request.timeoutInterval = timeOut;
    
    NSString *url_action = [NSString stringWithFormat:@"/%@/",k_action];
    if ([urlString containsString:url_action]) {
        [self setHTTPBody:request body:nil];
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    NSURLSessionTask *myDataTask = [_session dataTaskWithRequest:request];
    [myDataTask resume];
    
    if ([fileName isEqualToString:@"wifi.bin"]) {
        NSLog(@"url = %@",urlString);
    }
    
    if (isShowActivity) {
//        UIActivityIndicatorView *activity = [[self class] getSuperView:[UIActivityIndicatorView class] from:_imgView];
//        if (!activity) {
//            activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)Type];
//            activity.center = CGPointMake(_imgView.frame.size.width/2, _imgView.frame.size.height/2);
//            activity.hidesWhenStopped = YES;
//            [_imgView addSubview:activity];
//        }
//        [activity startAnimating];
    }
}

- (void)setHTTPBody:(NSMutableURLRequest *)urlRequest body:(NSDictionary *)body
{
    NSError *error;
    body = body ?: @{};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error: &error];
    [urlRequest setHTTPMethod:@"POST"];//设置为 POST
    //[URLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //[URLRequest setValue:[NSString stringWithFormat:@"%ld",(long)[jsonData length]] forHTTPHeaderField:@"Content-length"];
    
    NSString *languageCode = [Tools getLocaleLangArea][@"lang"];//en_CN,zh_CN(语言_地区)
    [urlRequest setValue:languageCode forHTTPHeaderField:@"lang"];
    [urlRequest setHTTPBody:jsonData];
}

- (void)cancelDownload
{
//    if (urlConnection) {
//        
//        [urlConnection cancel];
//        
//        for (UIView *activity in _imgView.subviews) {
//            if ([activity isKindOfClass:UIActivityIndicatorView.class]) {
//                [(UIActivityIndicatorView *)activity stopAnimating];
//            }
//        }
//    }
    [_session invalidateAndCancel];
}

+ (id)getSuperView:(Class)aClass from:(NSView *)View
{
    id obj = nil;
    for (NSView* next = [View superview]; next; next = next.superview) {
        
        if ([next isKindOfClass:aClass]) {
            obj = next;
            break;
        }
        
        NSResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:aClass]) {
            obj = (NSTableView *)nextResponder;
            //NSLog(@"%@",cell);
            break;
        }
    }
    
    return obj;
}

- (void)setProgress:(CGFloat)progress
{
    NSTimeInterval space = [[NSDate date] timeIntervalSinceDate:sendDate];
    if (space < 0.02 && progress != 1.0) {
        //NSString *msg = @"----------接收进度没有更新--------------------";
        //[CTB printDebugMsg:msg];
        return;
    }
    
    sendDate = [NSDate date];
    currentRate = progress;
    //NSLog(@"progress = %f",progress);
    id obj = delegate;
    if ([obj respondsToSelector:@selector(setProgress:)]) {
        [delegate setProgress:progress];
    }
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    //收到服务器响应回调
    _response = (NSHTTPURLResponse *)response;
    _headerFields = _response.allHeaderFields;
    _statusCode = (int)_response.statusCode;
    contentLength = [_headerFields[@"Content-Length"] longLongValue];
    _dataType = response.MIMEType;
    //NSLog(@"File Size:%lld",contentLength);
    isFailed = _statusCode != 200;
    if (isFailed) {
        NSLog(@"响应错误,%@,%ld",_method,_statusCode);
    }
    
    if (_isShowLog) {
        NSLog(@"收到服务器响应,内容长度：%lld",contentLength);
    }
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [activeDownload appendData:data];
    
    if (isFailed) {
        return;
    }
    
    CGFloat totalLen = contentLength;
    CGFloat rate = activeDownload.length / totalLen;
    [self setProgress:rate];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        id obj = delegate;
        if ([obj respondsToSelector:@selector(downLoadFail:)]) {
            _errMsg = error.localizedDescription;
            [delegate downLoadFail:self];
        }
        else if (_isDisplay) {
            NSLog(@"%@,%@",task.currentRequest.URL,error.localizedDescription);
        }
    }else{
        _responseData = activeDownload;
        if (_statusCode != 200) {
            //请求失败
            id obj = delegate;
            NSString *textEncodingName = _response.textEncodingName ?: @"utf-8";
            CFStringRef textEncode = (__bridge CFStringRef)textEncodingName;
            CFStringEncoding enc = CFStringConvertIANACharSetNameToEncoding(textEncode);
            NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (enc);
            NSString *string = [[NSString alloc] initWithData:activeDownload encoding: encoding];
            
            if ([obj respondsToSelector:@selector(downLoadFail:)]) {
                _errMsg = NSLocalizedString(@"DownLoadFail",@"文件下载失败");//文件下载失败
                if (string) {
                    _errMsg = [GDataXMLNode getBody:string];
                }
                [delegate downLoadFail:self];
            }
            else if (_isDisplay) {
                NSLog(@"%@,%@",task.currentRequest.URL,_errMsg);
            }
            
            return;
        }
        
        if (activeDownload.length<2) {
            NSLog(@"NOT FILE");
        }else{
            NSString *type = [activeDownload getDtataType];//判断数据对应文件类型
            if (!type || ![fileName hasSuffix:type]) {
                NSLog(@"%@",fileName);
            }
        }
        
        NSString *ExtName = [fileName.pathExtension lowercaseString];
        if([ExtName hasSuffix:@"png"] || [ExtName hasSuffix:@"img"] || [ExtName hasSuffix:@"gif"] || [ExtName hasSuffix:@"jpeg"] || [ExtName hasSuffix:@"jpg"]) {
            
            NSImage *image = [[NSImage alloc] initWithData:activeDownload];
            if (image) {
                
                //            if (isAutoSave) [Tools saveDataToFile:activeDownload fileName:fileName];
                id obj = delegate;
                if ([obj respondsToSelector:@selector(downLoadOK:)]) {
                    _image = image;
                    [delegate downLoadOK:self];
                }
                else if (_isDisplay && [_imgView isKindOfClass:[NSImageView class]]) {
                    _imgView.image = _image;
                }
            }else{
                id obj = delegate;
                if ([obj respondsToSelector:@selector(downLoadFail:)]) {
                    _errMsg = NSLocalizedString(@"DownLoadFail",@"文件下载失败");//文件下载失败
                    [delegate downLoadFail:self];
                }
                else if (_isDisplay) {
                    NSLog(@"%@,%@",task.currentRequest.URL,_errMsg);
                }
            }
        }
        else {
            
            //        if (isAutoSave) [Tools saveDataToFile:activeDownload fileName:fileName];
            id obj = delegate;
            if ([obj respondsToSelector:@selector(downLoadOK:)]) {
                [delegate downLoadOK:self];
            }
            else if (_isDisplay) {
                NSLog(@"%@,%@",task.currentRequest.URL,_errMsg);
            }
        }
    }
}

@end
