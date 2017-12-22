//
//  IconDownload.h
//  iCaidan
//
//  Created by jxyxhama on 11-11-27.
//  Copyright 2011年 彩旦科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

//活动指示器类型 0: 白大 1:小白 2:小灰
//typedef NS_ENUM(NSInteger, ActivityStyle)
//{
//    ActivityStyle_WhiteLarge = NSActivityIndicatorViewStyleWhiteLarge,
//    ActivityStyle_White = UIActivityIndicatorViewStyleWhite,
//    ActivityStyle_Gray = UIActivityIndicatorViewStyleGray
//};

@class FileDownloader;
@protocol FileDownloaderDelegate

@optional

- (void)setProgress:(CGFloat)progress;
- (void)downLoadOK:(FileDownloader *)loader;
- (void)downLoadFail:(FileDownloader *)loader;

@end

@interface FileDownloader : NSObject<FileDownloaderDelegate>
{
@public
    long long contentLength;
    CGFloat currentRate;
    BOOL isFailed;
    
    NSDate *sendDate;
    NSIndexPath *indexPath;
    NSMutableData *activeDownload;
//    NSURLConnection *urlConnection;
    
    NSString *fileName;
    NSString *fileType;
}

@property (nonatomic) NSTimeInterval timeOut;//超时时间
@property (nonatomic) BOOL isShowActivity;//显示活动指示器
//@property (nonatomic) ActivityStyle Type;//指示器类型
@property (nonatomic, retain) NSString *hostPort;
@property (nonatomic, assign) int tag;
@property (nonatomic, weak) id delegate;
@property (nonatomic, retain) NSURLSession *session;
@property (nonatomic, retain) NSString *method;

@property (nonatomic) BOOL isDisplay;//自动显示
@property (nonatomic) BOOL isShowLog;//显示Log

@property (nonatomic) BOOL isAutoSave;//自动保存数据(默认为YES)
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSImageView *imgView;
@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) id userInfo;

/*返回数据属性*/
@property (nonatomic, retain, readonly) NSHTTPURLResponse *response;
@property (nonatomic, assign, readonly) long statusCode;//网络请求响应代号
@property (nonatomic, retain, readonly) NSString *dataType;//网络数据类型
@property (nonatomic, retain, readonly) NSString *errMsg;//网络请求错误信息
@property (nonatomic, retain, readonly) NSDictionary *headerFields;//网络请求响应信息体(head)
@property (nonatomic, retain, readonly) NSData *responseData;//收到的数据

- (void)setData:(NSDictionary *)dicData delegate:(id)delegate;
- (void)setImg:(NSImageView *)imgView fileUrl:(NSString *)fileUrl fileName:(NSString *)theFileName delegate:(id<FileDownloaderDelegate>)theDelegate;
- (void)downWithUrl:(NSString *)fileUrl fileName:(NSString *)theFileName;

- (void)cancelDownload;

@end


