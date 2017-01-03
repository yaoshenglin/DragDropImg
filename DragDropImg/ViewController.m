//
//  ViewController.m
//  DragDropImg
//
//  Created by xy on 2016/12/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSString *path1;
    NSString *path2;
}

@property (nonatomic, retain) NSData *oldData;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCapacity];
    // Do any additional setup after loading the view.
}

- (void)initCapacity
{
    self.oldData = nil;
}

- (void)setOldData:(NSData *)oldData
{
    NSButton *button = [self.view viewWithTag:2];
    button.enabled = oldData ? YES : NO;
    _oldData = oldData;
}

- (void)dropComplete:(DragDropImageView *)dragImgView
{
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
}

- (IBAction)ReplaceImgEvents:(NSButton *)sender
{
    if (path1.length > 0 && path2.length > 0) {
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
    }
}

- (IBAction)backReplaceEvents:(NSButton *)sender
{
    if (self.oldData == nil) {
        return;
    }
    
    [self.oldData writeToFile:path2 atomically:YES];
    
    _dragImgView2.image = [[NSImage alloc] initWithData:self.oldData];
    CGSize imgSize = _dragImgView2.image.size;
    NSString *content = [NSString stringWithFormat:@"%.1f X %.1f",imgSize.width,imgSize.height];
    _imgInfo2.stringValue = content;
    
    self.oldData = nil;
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
