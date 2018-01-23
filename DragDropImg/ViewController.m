//
//  ViewController.m
//  DragDropImg
//
//  Created by xy on 2016/12/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "ViewController.h"
#import "Tools.h"
#import "PackageXMLParser.h"
#import "GDataXMLNode.h"

@interface ViewController ()<NSXMLParserDelegate>
{
    NSString *path1;//图片1路径
    NSString *path2;//图片2路径
    
    NSView *hintView;
}

@property (nonatomic, retain) NSData *oldData;
@property(nonatomic,strong) NSString *currentString;

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
    
    NSMenu *newMenu = [[NSMenu alloc] init];
    NSMenuItem *openItem = [[NSMenuItem alloc] initWithTitle:@"NetRequest" action:@selector(menuItemEvents:) keyEquivalent:@""];
    openItem.target = self;
    [newMenu addItem:openItem];
    
    NSMenuItem *DrawImg = [[NSMenuItem alloc] initWithTitle:@"DrawImg" action:@selector(menuItemEvents:) keyEquivalent:@""];
    DrawImg.target = self;
    [newMenu addItem:DrawImg];
    
    NSMenuItem *CodeProtocol = [[NSMenuItem alloc] initWithTitle:@"CodeProtocol" action:@selector(menuItemEvents:) keyEquivalent:@""];
    CodeProtocol.target = self;
    [newMenu addItem:CodeProtocol];
    
    NSMenuItem *MakeQrCode = [[NSMenuItem alloc] initWithTitle:@"MakeQrCode" action:@selector(menuItemEvents:) keyEquivalent:@""];
    MakeQrCode.target = self;
    [newMenu addItem:MakeQrCode];
    _btnNext.menu = newMenu;
    
//    NSDictionary *userInfo = @{@"mobile":@"18602561935",
//                               @"token":@"301|E21CA9946944987340C1DA235AC2A73C",
//                               @"Salt":@"a0367a36a4bf2db0"};
//    [Tools setObject:userInfo forKey:@"userInfo"];
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

- (IBAction)NextButtonEvents:(NSButton *)sender
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *title = [infoDict objectForKey:@"NSMainStoryboardFile"];
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:title bundle:nil];
    NSViewController *Second = [storyBoard instantiateControllerWithIdentifier:@"Second"];
    [self presentViewControllerAsModalWindow:Second];
}

- (IBAction)ReplaceImgEvents:(NSButton *)sender
{
    //GetLastVersio.html,weather.xml,video.xml
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GetLastVersio.html" ofType:@""];
    NSData *data = [NSData dataWithContentsOfFile:path];
    // 创建解析器
//    PackageXMLParser *xmlParser = [PackageXMLParser xmlWithData:data];
//    xmlParser.isShowLog = YES;
    // 开始解析
//    [xmlParser parse];
    NSString *content = [PackageXMLParser getBodyWithData:data];
    NSLog(@"%@",content);
    
    if (!_dragImgView1.image || !_dragImgView2.image) {
        NSLog(@"请添加对应图片");
        
        //[Tools alertWithMessage:@"无法替换" informative:@"请添加原图片和替换图片" sheetHandler:nil];
        
        return;
    }
    
    if (hintView.layer.backgroundColor != [NSColor greenColor].CGColor) {
        __weak typeof(self) wSelf = self;
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"存在异常";
        alert.informativeText = @"图片有差异，是否继续替换";
        alert.alertStyle = NSAlertStyleInformational;
        [alert addButtonWithTitle:@"取消"];
        [alert addButtonWithTitle:@"确定"];
        alert.icon = [NSImage imageNamed:@"iface主机"];
        NSModalResponse returnCode = [alert runModal];
        NSInteger index = returnCode - NSAlertFirstButtonReturn;
        NSString *btnTitle = [alert.buttons[index] title];
        if ([btnTitle isEqualToString:@"确定"]) {
            //响应第一个按钮被按下
            [wSelf replaceImgOperation];
        }
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

#pragma mark - --------右键菜单事件回调------------------------
- (void)menuItemEvents:(NSMenuItem *)menuItem
{
    NSLog(@"%@",menuItem.title);
    if ([menuItem.title isEqualToString:@"NetRequest"]) {
        NSViewController *Second = [self.storyboard instantiateControllerWithIdentifier:@"Second"];
        [self presentViewControllerAsModalWindow:Second];
    }
    else if ([menuItem.title isEqualToString:@"DrawImg"]) {
        NSViewController *DrawImage = [self.storyboard instantiateControllerWithIdentifier:@"DrawImage"];
        [self presentViewControllerAsModalWindow:DrawImage];
    }
    else if ([menuItem.title isEqualToString:@"CodeProtocol"]) {
        NSViewController *CodeProtocol = [self.storyboard instantiateControllerWithIdentifier:@"CodeProtocol"];
        [self presentViewControllerAsModalWindow:CodeProtocol];
    }
    else if ([menuItem.title isEqualToString:@"MakeQrCode"]) {
        NSViewController *CodeProtocol = [self.storyboard instantiateControllerWithIdentifier:@"MakeQrCode"];
        [self presentViewControllerAsModalWindow:CodeProtocol];
    }
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    NSRect rect = _dragImgView2.frame;
    CGFloat w = CGRectGetWidth(hintView.frame);
    hintView.frame = CGRectMake(CGRectGetMaxX(rect)+20, CGRectGetMidY(rect)-w/2, w, w);
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
