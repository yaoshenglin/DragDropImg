//
//  CodeProtocol_ViewController.m
//  DragDropImg
//
//  Created by xy on 2017/12/28.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "CodeProtocol_ViewController.h"
//#import <QuickLook/QuickLook.h>
#import <AppKit/NSDocument.h>
#import "Tools.h"
#import "DrawImage.h"

@interface CodeProtocol_ViewController ()<NSOpenSavePanelDelegate>
{
    NSTableView *myTableView;
    CGFloat space;
    
    DrawImage *drawView;
}

@end

@implementation CodeProtocol_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCapacity];
    // Do view setup here.
}

- (void)initCapacity
{
    NSTextView *textView = _infoView.documentView;
    textView.editable = NO;
    space = _directListView.frame.origin.x;
    NSLog(@"space = %f",space);
    
    drawView = [[DrawImage alloc] initWithFrame:self.view.bounds];
    drawView.layerContentsPlacement = NSViewLayerContentsPlacementCenter;
    [self.view addSubview:drawView];
    
    drawView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDic = NSDictionaryOfVariableBindings(drawView);
    [self.view addConstraintsWithFormat:@"|[drawView]|" views:viewsDic];
    [self.view addConstraintsWithFormat:@"V:|[drawView]|" views:viewsDic];
    drawView.hidden = YES;
}

- (IBAction)selectFromFile:(NSButton *)sender
{
    //选择文件
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.delegate = self;
    panel.showsHiddenFiles = YES;
    panel.allowedFileTypes = @[@"doc",@"docx"];
    panel.canChooseDirectories = NO;
    
    //NSString *dirPath = [[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent];
    //dirPath = [dirPath stringByAppendingPathComponent:@"Downloads"];
    //panel.directoryURL = [NSURL URLWithString:dirPath];
    NSWindow *window = [Tools getLastWindow];
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        NSLog(@"%ld",result);
    }];
    //[panel runModal];
}

#pragma mark - --------选择文件事件回调------------------------
- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url
{
    //将要选择的文件
    //NSLog(@"shouldEnableURL,%@",url.path);
    return YES;
}

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError
{
    NSLog(@"path = %@",url.path);
    //选定后并点击打开的文件
    NSDictionary *dic = nil;
    NSAttributedString *string = [[NSAttributedString alloc] initWithURL:url documentAttributes:&dic];
    //NSLog(@"%@",string.string);
    NSTextView *textView =  _infoView.documentView;
    textView.string = string.string;
    [textView insertText:string replacementRange:NSMakeRange(0, string.length)];
    
    drawView.hidden = NO;
    drawView.string = string;
    
    return YES;
}

- (void)stringWithURL:(NSURL *)url
{
    
}

@end
