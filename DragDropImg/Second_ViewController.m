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
            [self downRequest];
        });
    });
}

- (void)uploadRequest
{
    NSDictionary *userInfo = [Tools objectForKey:@"userInfo"];
    NSString *token = [userInfo stringForKey:@"token"];
    NSString *imgName = @"按钮点击效果";
    NSImage *image = [NSImage imageNamed:imgName];
    
    NSDictionary *body = @{@"file":image,@"fileName":imgName};
    UploadFile *load = [[UploadFile alloc] init];
    [load run:UpdateSceneImg body:body delegate:self];
    [load addRequestHeader:@{@"token":token} encoding:NSUTF8StringEncoding];
    [load addRequestHeader:@{@"SceneID":@(692)} encoding:NSUTF8StringEncoding];
    [load start];
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
}

- (void)wsFailed:(HTTPRequest *)iWS
{
    NSString *errMsg = iWS.errMsg;
    NSLog(@"%@,%d,%@",iWS.method,iWS.responseStatusCode,errMsg);
}

@end
