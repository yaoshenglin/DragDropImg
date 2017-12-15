//
//  Second_ViewController.m
//  DragDropImg
//
//  Created by xy on 2017/12/14.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "Second_ViewController.h"
#import "MyHttpRequest.h"
#import "DataRequest.h"
#import "DownloadRequest.h"

@interface Second_ViewController ()
{
    DataRequest *dataRequest;
    DownloadRequest *downRequest;
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
    dataRequest = [[DataRequest alloc] init];
    dataRequest.delegate = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [NSThread sleepForTimeInterval:0.5];
        dispatch_async(dispatch_get_main_queue(), ^{
            [dataRequest startRequest];
        });
    });
}

- (IBAction)SuspendEvents:(NSButton *)sender
{
    [downRequest suspend];
}

- (IBAction)CancelEvents:(NSButton *)sender
{
    [downRequest cancel];
}

- (IBAction)BackButtonEvents:(NSButton *)sender
{
    [self dismissController:nil];
}

#pragma mark -
- (void)downloadToProgress:(CGFloat)progress rate:(CGFloat)rate
{
    NSString *speedString = [NSString stringWithFormat:@"%.2lfB/s", rate];
    if (rate > 1024) {
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
    [downRequest cancel];
}

@end
