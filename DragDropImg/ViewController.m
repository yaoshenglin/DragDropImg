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

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)dropComplete:(DragDropImageView *)dragImgView
{
    NSLog(@"%@",dragImgView.path);
    CGSize imgSize = dragImgView.image.size;
    NSString *content = [NSString stringWithFormat:@"%.1f X %.1f",imgSize.width,imgSize.height];
    if (dragImgView == _dragImgView1) {
        _imgInfo1.stringValue = content;
        path1 = dragImgView.path;
    }
    else if (dragImgView == _dragImgView2) {
        _imgInfo2.stringValue = content;
        path2 = dragImgView.path;
    }
}

- (IBAction)ReplaceImgEvents:(NSButton *)sender
{
    if (path1.length > 0 && path2.length > 0) {
        NSData *data = [NSData dataWithContentsOfFile:path1];
        BOOL result = [data writeToFile:path2 atomically:YES];
        if (!result) {
            NSError *error = [NSError errorWithDomain:@"替换失败" code:0 userInfo:@{NSLocalizedDescriptionKey:@"the content is nil"}];
            NSLog(@"%@",error.localizedDescription);
            NSAlert *alert = [NSAlert alertWithError:error];
            alert.messageText = @"替换失败";
            [alert addButtonWithTitle:@"确定"];
            [alert runModal];
        }else{
            _dragImgView2.image = [[NSImage alloc] initWithData:data];
            CGSize imgSize = _dragImgView2.image.size;
            NSString *content = [NSString stringWithFormat:@"%.1f X %.1f",imgSize.width,imgSize.height];
            _imgInfo2.stringValue = content;
        }
    }
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
