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
#import "UploadFile.h"
#import "Tools.h"

@interface Second_ViewController ()<NSOpenSavePanelDelegate>
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
    
    
    _txtURL.stringValue = [HTTPRequest initUrl:GetLastVersions];
    _txtURL.maximumNumberOfLines = 1;
    _txtURL.refusesFirstResponder = YES;
    _txtFile.stringValue = @"/Users/xy/Library/Developer/Xcode/DerivedData/DragDropImg-bgyaoueutozmwweewybfgccinuzg/Build/Products/Debug/DragDropImg.app/Contents/Downloads/20171221172629561.jpg";
    _txtFile.maximumNumberOfLines = 1;
    _txtDown.stringValue = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V6.2.0.dmg";
    _txtDown.maximumNumberOfLines = 1;
    _txtDown.refusesFirstResponder = YES;
}

- (void)initCapacity
{
    
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
    request.urlString = _txtURL.stringValue;
    [request run:nil body:body];
    [request start];
}

- (void)uploadRequest
{
    //选择文件
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.delegate = self;
    //panel.allowedFileTypes = @[@"cer"];
    //panel.canChooseDirectories = YES;
    
    NSString *dirPath = [[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent];
    dirPath = [dirPath stringByAppendingPathComponent:@"Downloads"];
    panel.directoryURL = [NSURL URLWithString:dirPath];
    [panel runModal];
}

- (void)uploadFileWithPath:(NSString *)path
{
    NSString *fileName = path.lastPathComponent;
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSDictionary *userInfo = [Tools objectForKey:@"userInfo"];
    NSString *token = [userInfo stringForKey:@"token"];
    NSDictionary *body = @{@"file":data,@"fileName":fileName,@"path":path};
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
    request.urlString = @"http://120.25.226.186:32812/resources/videos/minion_01.mp4";
    request.urlString = @"http://res.weicontrol.cn/Content/Uploads/301/scene/20171221172629561.jpg";
    request.urlString = _txtDown.stringValue;
    request.taskType = SessionTaskType_Download;
    request.isShowErrmsg = YES;
    [request run:nil body:nil];
    [request start];
}

- (IBAction)requestTask:(NSButton *)sender
{
    if (sender.tag == 1) {
        [self dataRequest];
    }
    else if (sender.tag == 2) {
        [self uploadRequest];
    }
    else if (sender.tag == 3) {
        [self downRequest];
    }
}


- (IBAction)SuspendEvents:(NSButton *)sender
{
    if (request.myDataTask.state == NSURLSessionTaskStateRunning) {
        [request suspend];
    }
    else if (request.myDataTask.state == NSURLSessionTaskStateSuspended) {
        [request resume];
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

#pragma mark - --------选择文件事件回调------------------------
- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url
{
    //将要选择的文件
    //NSLog(@"shouldEnableURL,%@",url.path);
    return YES;
}

#pragma mark 已经选择了文件
- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError
{
    //选定后并点击打开的文件
    _txtFile.stringValue = url.path;
    [self uploadFileWithPath:url.path];
    
    return YES;
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
        }else{
            NSLog(@"%@",dirPath);
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
    
    if (![iWS.dataType hasSuffix:@"/json"]) {
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
        }else{
            NSLog(@"%@",dirPath);
        }
    }else{
        NSLog(@"%@",iWS.responseString);
    }
}

- (void)dealloc
{
    NSLog(@"%@",self.className);
}

@end
