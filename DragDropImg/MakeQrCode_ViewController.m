//
//  MakeQrCode_ViewController.m
//  DragDropImg
//
//  Created by xy on 2018/1/3.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "MakeQrCode_ViewController.h"
#import <CoreImage/CoreImage.h>
#import "Tools.h"

@interface MakeQrCode_ViewController ()

@end

@implementation MakeQrCode_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCapacity];
    // Do view setup here.
}

- (void)initCapacity
{
    _txtContent.stringValue = @"d:code;k:039d02f45e3a72ce;m:188****5377;t:1;";
}

- (IBAction)GenerateQrCode:(NSButton *)button
{
    NSString *stringValue = _txtContent.stringValue;
    if (stringValue.length <= 0) {
        [Tools alertWithMessage:@"文本错误" informative:@"输入内容不能为空" sheetHandler:nil];
        return;
    }
    
    NSImage *image = [Tools generateWithQRCodeData:stringValue frame:_imgViewCode.frame];
    _imgViewCode.image = image;
    
    button = [self.view subviewWithClass:[NSButton class] tag:2];
    button.enabled = YES;
}

- (IBAction)ButtonEvents:(NSButton *)button
{
    if (button.tag == 2) {
        NSImage *image = _imgViewCode.image;
        NSData *data = [image TIFFRepresentation];
        NSSavePanel *savePanel = [NSSavePanel savePanel];
        NSArray *listTypes = @[@"png",@"jpg"];
        [savePanel setAllowedFileTypes:listTypes];
        [savePanel setCanSelectHiddenExtension:NO];
        savePanel.showsHiddenFiles = YES;
        NSWindow *window = [Tools getLastWindow];
        [savePanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
            if (result == NSModalResponseOK) {
                BOOL isWrite = [data writeToURL:savePanel.URL atomically:YES];
                if (!isWrite) {
                    [Tools alertWithMessage:@"保存错误" informative:@"图片保存失败" sheetHandler:nil];
                }else{
                    NSLog(@"%@",savePanel.URL.path);
                }
            } else {
                NSLog(@"操作取消");
            }
        }];
    }
}

@end
