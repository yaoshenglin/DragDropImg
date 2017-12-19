//
//  IconDownload.h
//  iCaidan
//
//  Created by jxyxhama on 11-11-27.
//  Copyright 2011年 彩旦科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

//台房状态 0: 未设置 1:已订 2:空闲
//typedef NS_ENUM(NSInteger, ActivityStyle)
//{
//    ActivityStyle_WhiteLarge = UIActivityIndicatorViewStyleWhiteLarge,
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
    long long contentLength;
    CGFloat currentRate;
    BOOL isFailed;
    
    NSDate *sendDate;
    NSIndexPath *indexPath;
    NSMutableData *activeDownload;
    NSURLConnection *urlConnection;
    
    __weak id <FileDownloaderDelegate> delegate;
    
    NSString *fileName;
    NSString *fileType;
    NSImageView *targetImgView;
}

@property (nonatomic) NSTimeInterval timeOut;//超时时间
@property (nonatomic) BOOL isShowActivity;//显示活动指示器
//@property (nonatomic) ActivityStyle Type;//指示器类型
@property (retain, nonatomic) NSString *hostPort;
@property (assign, nonatomic) int tag;
@property (weak, nonatomic) id delegate;

@property (nonatomic) BOOL isDisplay;//自动显示

@property (retain, nonatomic) NSString *fileName;
@property (retain, nonatomic) NSString *urlString;
@property (retain, nonatomic) NSImageView *imgView;
@property (retain, nonatomic) NSImage *image;
@property (assign, nonatomic, readonly) NSInteger statusCode;//网络请求响应代号
@property (retain, nonatomic, readonly) NSString *errMsg;//网络请求错误信息
@property (retain, nonatomic, readonly) NSDictionary *userInfo;//网络请求响应信息体(head)
@property (retain, nonatomic, readonly) NSData *responseData;

- (void)setData:(NSDictionary *)dicData delegate:(id)delegate;
- (void)setImg:(NSImageView *)imgView fileUrl:(NSString *)fileUrl fileName:(NSString *)theFileName delegate:(id<FileDownloaderDelegate>)theDelegate;

- (void)cancelDownload;

@end


