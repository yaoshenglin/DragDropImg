//
//  Second_ViewController.m
//  DragDropImg
//
//  Created by xy on 2017/12/14.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "Second_ViewController.h"
#import "ExportGather.h"
#import "HTTPRequest.h"
#import "FileDownloader.h"
#import "UploadFile.h"
#import "Tools.h"

@interface Second_ViewController ()
{
    HTTPRequest *request;
}

@property (nonatomic, retain) NSTextField *textField;

@end

@implementation Second_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
    [self initCapacity];
    // Do view setup here.
}

- (void)setupSubviews
{
    CGRect frame = CGRectMake(0, self.view.frame.size.height-20, 120, 20);
    _textField = [[NSTextField alloc] initWithFrame:frame];
    _textField.editable = NO;
    _textField.bordered = NO;
    _textField.backgroundColor = [NSColor clearColor];
    [self.view addSubview:_textField];
}

- (void)initCapacity
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [NSThread sleepForTimeInterval:0.5];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dataRequest];
        });
    });
}

- (void)dataRequest
{
    NSInteger appVer = 33;//当前APP内部版本号
    NSInteger hwVer = 2;//当前固件内部版本号
    NSString *hwName = @"ModelName";
    NSDictionary *body = @{@"deviceType":@(4),//4
                           @"appVer":@(appVer),
                           @"hwName":hwName,
                           @"hwVer":@(hwVer)};
    request = [[HTTPRequest alloc] initWithDelegate:self];
    [request run:GetLastVersions body:body];
    [request start];
}

- (void)uploadRequest
{
    NSDictionary *userInfo = [Tools objectForKey:@"userInfo"];
    NSString *token = [userInfo stringForKey:@"token"];
    NSString *imgName = @"msg2";
    NSImage *image = [NSImage imageNamed:imgName];
    
    NSDictionary *body = @{@"file":image,@"fileName":imgName};
    request = [[HTTPRequest alloc] initWithDelegate:self];
    request.taskType = SessionTaskType_Upload;
    [request run:UpdateSceneImg body:body delegate:self];
    [request setValue:token forHeader:@"token" encoding:NSUTF8StringEncoding];
    [request setValue:@(692).stringValue forHeader:@"SceneID" encoding:NSUTF8StringEncoding];
    [request start];
}

- (void)downRequest
{
    request = [[HTTPRequest alloc] initWithDelegate:self];
    request.urlString = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V6.2.0.dmg";
    [request run:nil body:nil];
    [request start];
}

- (IBAction)SuspendEvents:(NSButton *)sender
{
    [request suspend];
    
    NSString *fileName = request.response.suggestedFilename;
    NSString *dirPath = @"/Volumes/Apple/应用软件";
    NSString *path = [dirPath stringByAppendingPathComponent:fileName];
    BOOL result = [request.responseData writeToFile:path atomically:YES];
    if (!result) {
        NSLog(@"写入失败,%@",path);
    }
}

- (IBAction)CancelEvents:(NSButton *)sender
{
    [request cancel];
}

- (IBAction)BackButtonEvents:(NSButton *)sender
{
    [self dismissController:nil];
}

#pragma mark -
- (void)downloadToProgress:(CGFloat)progress rate:(CGFloat)rate
{
    NSString *speedString = [NSString stringWithFormat:@"%.2lfB/s", rate];
    if (rate > 1024 && rate <= 1024 * 1024) {
        speedString = [NSString stringWithFormat:@"%.2lfKB/s", rate / 1024];
    }
    else if (rate > 1024 * 1024) {
        speedString = [NSString stringWithFormat:@"%.2lfMB/s", rate / 1024 / 1024];
    }
    
    dispatch_block_t block = ^{
        _textField.stringValue = speedString;
    };
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), block);
    }else{
        block();
    }
}

- (void)receiveProgress:(CGFloat)progress
{
    NSString *speedString = [NSString stringWithFormat:@"接收进度:%.2f%%",progress/0.01];
    
    dispatch_block_t block = ^{
        _textField.stringValue = speedString;
    };
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), block);
    }else{
        block();
    }
}

- (void)viewDidDisappear
{
    [super viewDidDisappear];
    [request cancel];
}

#pragma mark - --------WSDelegate----------------
- (void)wsOK:(HTTPRequest *)iWS
{
    NSDictionary *jsonDic = iWS.jsonDic;
    if ([iWS.method isEqualToString:UpdateSceneImg]) {
        NSString *imgUrl = [jsonDic stringForKey:@"data"];//新的图片地址
        NSLog(@"imgUrl = %@",imgUrl);
    }
    else if ([iWS.method isEqualToString:FileDownload]) {
        NSString *fileName = iWS.response.suggestedFilename;
        NSString *dirPath = [[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent];
        dirPath = [dirPath stringByAppendingPathComponent:@"Downloads"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:dirPath]) {
            [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *path = [dirPath stringByAppendingPathComponent:fileName];
        BOOL result = [iWS.responseData writeToFile:path atomically:YES];
        if (!result) {
            NSLog(@"写入失败,%@",path);
        }
    }
    else if ([iWS.method isEqualToString:GetLastVersions]) {
        NSLog(@"%@",[jsonDic customDescription]);
    }
}

- (void)wsFailed:(HTTPRequest *)iWS
{
    NSString *errMsg = iWS.errMsg;
    NSLog(@"%@,%d,%@",iWS.method,iWS.responseStatusCode,errMsg);
}

@end
