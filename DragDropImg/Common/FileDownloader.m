//
//  IconDownload.m
//  iCaidan
//
//  Created by jxyxhama on 11-11-27.
//  Copyright 2011年 彩旦科技. All rights reserved.
//

#import "FileDownloader.h"
#import "Tools.h"
#import "AppDelegate.h"
//#import "GDataXMLNode.h"
//#import "CTB.h"

@implementation FileDownloader

@synthesize fileName;
@synthesize timeOut;
@synthesize isShowActivity;
//@synthesize Type;
@synthesize delegate;
@synthesize hostPort;

- (id)init
{
    self = [super init];
    if (self) {
//        Type = ActivityStyle_WhiteLarge;
        fileName = @"";
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
    
    targetImgView = imgView;
    delegate = theDelegate;
    fileName = theFileName;
    
    NSString *urlString;
    
    if ([fileUrl hasPrefix:@"http"]) {
        urlString = fileUrl;
    }
    else {
        NSString *host = k_res_host;
        urlString = [NSString stringWithFormat:@"%@%@", host, fileUrl];
    }
    
    self.urlString = urlString;
    self.imgView = imgView;
    activeDownload = [NSMutableData data];
    NSURL *URL = [NSURL URLWithString:urlString];
    timeOut = timeOut==0 ? 60 : timeOut;
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:timeOut];
    urlConnection = [[NSURLConnection alloc] initWithRequest: URLRequest delegate:self];
    
    if (isShowActivity) {
//        UIActivityIndicatorView *activity = [[self class] getSuperView:[UIActivityIndicatorView class] from:targetImgView];
//        if (!activity) {
//            activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)Type];
//            activity.center = CGPointMake(targetImgView.frame.size.width/2, targetImgView.frame.size.height/2);
//            activity.hidesWhenStopped = YES;
//            [targetImgView addSubview:activity];
//        }
//        [activity startAnimating];
    }
}

- (void)setHTTPBody:(NSMutableURLRequest *)URLRequest body:(NSDictionary *)body
{
    NSError *error;
    body = body ?: @{};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error: &error];
    [URLRequest setHTTPMethod:@"POST"];//设置为 POST
    [URLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [URLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [URLRequest setValue:[NSString stringWithFormat:@"%ld",(long)[jsonData length]] forHTTPHeaderField:@"Content-length"];
    [URLRequest setHTTPBody:jsonData];
}

- (void)cancelDownload
{
    if (urlConnection) {
        
        [urlConnection cancel];
    }
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
        NSString *msg = @"----------接收进度没有更新--------------------";
        NSLog(@"%@",msg);
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;
    _userInfo = theResponse.allHeaderFields;
    _statusCode = theResponse.statusCode;
    contentLength = [_userInfo[@"Content-Length"] longLongValue];
    //NSLog(@"File Size:%lld",contentLength);
    isFailed = _statusCode != 200;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [activeDownload appendData:data];
    
    if (isFailed) {
        return;
    }
    
    CGFloat totalLen = contentLength;
    CGFloat rate = activeDownload.length / totalLen;
    [self setProgress:rate];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//    for (UIActivityIndicatorView *activity in targetImgView.subviews) {
//        if ([activity isKindOfClass:[UIActivityIndicatorView class]]) {
//            [activity stopAnimating];
//        }
//    }
    
    id obj = delegate;
    if ([obj respondsToSelector:@selector(downLoadFail:)]) {
        _errMsg = error.localizedDescription;
        [delegate downLoadFail:self];
    }
    else if (_isDisplay) {
        NSLog(@"%@,%@",connection.currentRequest.URL,error.localizedDescription);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    for (UIActivityIndicatorView *activity in targetImgView.subviews) {
//        if ([activity isKindOfClass:[UIActivityIndicatorView class]]) {
//            [activity stopAnimating];
//        }
//    }
    
    _responseData = activeDownload;
    if (_statusCode != 200) {
        //请求失败
        id obj = delegate;
        NSString *string = [[NSString alloc] initWithData:activeDownload encoding:NSUTF8StringEncoding];
        if (!string) {
            NSStringEncoding encoding = 0x80000632;
            string = [[NSString alloc] initWithData:activeDownload encoding:encoding];
        }

        if ([obj respondsToSelector:@selector(downLoadFail:)]) {
            _errMsg = @"文件下载失败";
            if (string) {
//                _errMsg = [GDataXMLNode getBody:string];
            }
            [delegate downLoadFail:self];
        }
        else if (_isDisplay) {
            NSLog(@"%@,%@",connection.currentRequest.URL,_errMsg);
        }
        
        return;
    }
    
    if([fileName hasSuffix:@".png"] || [fileName hasSuffix:@".PNG"]
       || [fileName hasSuffix:@".img"] || [fileName hasSuffix:@".IMG"]
       || [fileName hasSuffix:@".gif"] || [fileName hasSuffix:@".GIF"]
       || [fileName hasSuffix:@".jpeg"] || [fileName hasSuffix:@".JPEG"]
       || [fileName hasSuffix:@".jpg"] || [fileName hasSuffix:@".JPG"]) {
        
        NSImage *image = [[NSImage alloc] initWithData:activeDownload];
        if (image) {
            
            //NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            //[Tools saveDataToFile:imageData fileName:fileName];
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
                _errMsg = @"文件下载失败";
                [delegate downLoadFail:self];
            }
            else if (_isDisplay) {
                NSLog(@"%@,%@",connection.currentRequest.URL,_errMsg);
            }
        }
    }
    else {
        
        //[Tools saveDataToFile:activeDownload fileName:fileName];
        id obj = delegate;
        if ([obj respondsToSelector:@selector(downLoadOK:)]) {
            [delegate downLoadOK:self];
        }
        else if (_isDisplay) {
            NSLog(@"%@,%@",connection.currentRequest.URL,_errMsg);
        }
    }
}

@end
