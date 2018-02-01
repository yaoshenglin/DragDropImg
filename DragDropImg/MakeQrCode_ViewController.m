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
{
    NSArray *listTitle;
    NSInteger index;
    
    NSString *stringValue;
}

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
    index = 0;
    _txtContent.stringValue = @"d:code;k:039d02f45e3a72ce;m:188****5377;t:1;";
    
    listTitle = @[@"文本",@"主机",@"开关",@"插座",@"门锁",@"车位锁",@"雾化窗玻",@"分控器",@"电动窗帘"];
    NSMenu *newMenu = [[NSMenu alloc] init];
    for (NSString *title in listTitle) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(menuItemEvents:) keyEquivalent:@""];
        item.target = self;
        [newMenu addItem:item];
    }
    
    _lblType.menu = newMenu;
}

#pragma mark - --------右键菜单事件回调------------------------
- (void)menuItemEvents:(NSMenuItem *)menuItem
{
    NSLog(@"%@",menuItem.title);
    _lblType.stringValue = menuItem.title;
    index = [listTitle indexOfObject:menuItem.title];
}

- (IBAction)GenerateQrCode:(NSButton *)button
{
    stringValue = _txtContent.stringValue;
    if (stringValue.length <= 0) {
        [Tools alertWithMessage:@"文本错误" informative:@"输入内容不能为空" sheetHandler:nil];
        return;
    }
    
    switch (index) {
        case 1:
            //主机
            stringValue = [NSString stringWithFormat:@"device:host;content:%@;tag:4;m:SW01;t:0;ver:2.0",stringValue];
            break;
        case 2:
            //开关(3目)
            stringValue = [NSString stringWithFormat:@"device:switch;id:%@;tag:3;m:CS23;t:0;ver:2.0",stringValue];
            break;
        case 3:
            //插座
            stringValue = [NSString stringWithFormat:@"device:plug;id:%@;m:CP11;t:0;ver:2.0",stringValue];
            break;
        case 4:
            //门锁
            stringValue = [NSString stringWithFormat:@"device:doorlock;id:%@;tag:2;m:DL32;t:0;ver:2.0",stringValue];
            break;
        case 5:
            //车位锁
            stringValue = [NSString stringWithFormat:@"device:parklock;id:%@;m:PL41;t:0;ver:2.0",stringValue];
            break;
        case 6:
            //雾化窗玻
            stringValue = [NSString stringWithFormat:@"device:fogglass;id:%@;m:FG51;t:0;ver:2.0",stringValue];
            break;
        case 7:
            //分控器
            stringValue = [NSString stringWithFormat:@"device:irrelay;id:%@;tag:1;m:IF53;t:0;ver:2.0",stringValue];
            break;
        case 8:
            //电动窗帘
            stringValue = [NSString stringWithFormat:@"device:curtain;id:%@;tag:0;m:CT61;t:0;ver:2.0",stringValue];
            break;
            
        default:
            break;
    }
    
    NSImage *image = [Tools generateWithQRCodeData:stringValue title:_txtContent.stringValue frame:_imgViewCode.frame];
    image.name = _txtContent.stringValue;
    _imgViewCode.image = image;
    
    button = [self.view subviewWithClass:[NSButton class] tag:2];
    button.enabled = YES;
    button = [self.view subviewWithClass:[NSButton class] tag:3];
    button.enabled = YES;
}

- (IBAction)ButtonEvents:(NSButton *)button
{
    if (button.tag == 2) {
        NSImage *image = _imgViewCode.image;
        [image lockFocus];
        //先设置 下面一个实例
        NSBitmapImageRep *bits = [[NSBitmapImageRep alloc] initWithFocusedViewRect:_imgViewCode.frame];
        [image unlockFocus];
        //再设置后面要用到得 props属性
        NSDictionary *imageProps = @{NSImageCompressionFactor:@(0.98)};//压缩率
        
        //之后 转化为NSData 以便存到文件中
        NSData *data = [bits representationUsingType:NSPNGFileType properties:imageProps];
        //NSData *data = [image TIFFRepresentation];
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
    else if (button.tag == 3) {
        
        NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 200, 38)];
        textField.stringValue = _imgViewCode.image.name;
        textField.textColor = [NSColor redColor];
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"保存错误";
        alert.informativeText = @"图片保存失败";
        alert.alertStyle = NSAlertStyleInformational;
        [alert addButtonWithTitle:@"确定"];
        [alert addButtonWithTitle:@"取消"];
        alert.accessoryView = textField;
        NSWindow *window = [Tools getLastWindow];
        [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertFirstButtonReturn) {
                NSImage *image = [Tools generateWithQRCodeData:stringValue title:textField.stringValue frame:_imgViewCode.frame];
                image.name = textField.stringValue;
                _imgViewCode.image = image;
            }
        }];
    }
}

@end
