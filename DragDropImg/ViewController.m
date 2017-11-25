//
//  ViewController.m
//  DragDropImg
//
//  Created by xy on 2016/12/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "ViewController.h"
#import "Tools.h"

@interface ViewController ()
{
    NSString *path1;
    NSString *path2;
    
    NSView *hintView;
}

@property (nonatomic, retain) NSData *oldData;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil

{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCapacity];
    // Do any additional setup after loading the view.
}

- (void)initCapacity
{
    self.oldData = nil;
    
    CGFloat w = 30;
    NSRect rect = _dragImgView2.frame;
    hintView = [[NSView alloc] initWithFrame:NSMakeRect(CGRectGetMaxX(rect)+20, 0, w, w)];
    hintView.wantsLayer = YES;
    [hintView setFrameOrigin:NSMakePoint(CGRectGetMaxX(rect)+20, CGRectGetMidY(rect)-w/2)];
    hintView.layer.backgroundColor = [NSColor redColor].CGColor;
    [self.view addSubview:hintView];
    
    hintView.layer.cornerRadius = CGRectGetWidth(hintView.frame)/2;
}

- (void)setOldData:(NSData *)oldData
{
    NSButton *button = [self.view viewWithTag:2];
    button.enabled = oldData ? YES : NO;
    _oldData = oldData;
}

- (void)dropComplete:(DragDropImageView *)dragImgView
{
    //拖动图片事件
    NSLog(@"%@",dragImgView.path);
    CGSize imgSize = dragImgView.image.size;
    NSString *content = [NSString stringWithFormat:@"%.1f X %.1f",imgSize.width,imgSize.height];
    if (dragImgView == _dragImgView1) {
        _imgInfo1.stringValue = content;
        path1 = dragImgView.path;
        _txtName1.stringValue = path1.lastPathComponent;
    }
    else if (dragImgView == _dragImgView2) {
        _imgInfo2.stringValue = content;
        path2 = dragImgView.path;
        _txtName2.stringValue = path2.lastPathComponent;
        
        self.oldData = nil;
    }
    
    if ([_txtName1.stringValue isEqualToString:_txtName2.stringValue] && NSEqualSizes(_dragImgView1.image.size, _dragImgView2.image.size)) {
        hintView.layer.backgroundColor = [NSColor greenColor].CGColor;
    }else{
        hintView.layer.backgroundColor = [NSColor redColor].CGColor;
    }
}

- (IBAction)ReplaceImgEvents:(NSButton *)sender
{
    if (hintView.layer.backgroundColor != [NSColor greenColor].CGColor) {
        __weak typeof(self) wSelf = self;
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"图片有差异，继续替换";
        //alert.informativeText = @"push结果";
        alert.alertStyle = NSAlertStyleInformational;
        [alert addButtonWithTitle:@"取消"];
        [alert addButtonWithTitle:@"确定"];
        NSWindow *window = [NSApplication sharedApplication].windows.firstObject;
        [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertSecondButtonReturn) {
                //响应第一个按钮被按下
                [wSelf replaceImgOperation];
            }
        }];
        return;
    }
    //替换图片
    if (path1.length > 0 && path2.length > 0) {
        sender.enabled = NO;
        [self replaceImgOperation];
        
        sender.enabled = YES;
    }
}

- (void)replaceImgOperation
{
    //替换图片
    if (path1.length > 0 && path2.length > 0) {
        self.view.acceptsTouchEvents = NO;
        self.oldData = [NSData dataWithContentsOfFile:path2];
        NSData *data = [NSData dataWithContentsOfFile:path1];
        BOOL result = [data writeToFile:path2 atomically:YES];
        if (!result) {
            NSError *error = [NSError errorWithDomain:@"替换失败" code:0 userInfo:@{NSLocalizedDescriptionKey:@"the content is nil"}];
            NSLog(@"%@",error.localizedDescription);
            NSAlert *alert = [NSAlert alertWithError:error];
            alert.messageText = @"替换失败";
            [alert addButtonWithTitle:@"确定"];
            [alert runModal];
            self.oldData = nil;
        }else{
            _dragImgView2.image = [[NSImage alloc] initWithData:data];
            CGSize imgSize = _dragImgView2.image.size;
            NSString *content = [NSString stringWithFormat:@"%.1f X %.1f",imgSize.width,imgSize.height];
            _imgInfo2.stringValue = content;
        }
        
        self.view.acceptsTouchEvents = YES;
    }
}

- (IBAction)backReplaceEvents:(NSButton *)sender
{
    //还原图片
    if (self.oldData == nil) {
        return;
    }
    
    sender.enabled = NO;
    self.view.acceptsTouchEvents = NO;
    [self.oldData writeToFile:path2 atomically:YES];
    
    _dragImgView2.image = [[NSImage alloc] initWithData:self.oldData];
    CGSize imgSize = _dragImgView2.image.size;
    NSString *content = [NSString stringWithFormat:@"%.1f X %.1f",imgSize.width,imgSize.height];
    _imgInfo2.stringValue = content;
    
    self.oldData = nil;
    
    sender.enabled = YES;
    self.view.acceptsTouchEvents = YES;
}

#pragma mark
//- (void)viewWillLayout
//{
//    [super viewWillLayout];
//    
//    NSRect rect = _dragImgView2.frame;
//    CGFloat w = CGRectGetWidth(rect);
//    [hintView setFrameOrigin:NSMakePoint(CGRectGetMaxX(rect)+20, CGRectGetMidY(rect)-w/2)];
//}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    NSRect rect = _dragImgView2.frame;
    CGFloat w = CGRectGetWidth(hintView.frame);
    hintView.frame = CGRectMake(CGRectGetMaxX(rect)+20, CGRectGetMidY(rect)-w/2, w, w);
    
    w = self.view.frame.size.width;
    [_txtName1 setOriginX:45 width:w/2-80];
    [_txtName2 setOriginX:w/2+45 width:w/2-80];
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
