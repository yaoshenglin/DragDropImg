//
//  ParseData_ViewController.m
//  DragDropImg
//
//  Created by xy on 2018/1/25.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "ParseData_ViewController.h"
#import "Tools.h"

@interface ParseData_ViewController ()<NSTableViewDelegate,NSTableViewDataSource>
{
    NSMutableArray *listTitle;
    NSMutableArray *listContent;
    
    NSColor *textColor;
    NSTableView *myTableView;
}

@end

@implementation ParseData_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubViews];
    [self initCapacity];
    // Do view setup here.
}

- (void)setupSubViews
{
    NSArray *listMenu = @[@"解析发送数据",@"解析接收数据"];
    NSMenu *newMenu = [[NSMenu alloc] init];
    for (NSString *title in listMenu) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(menuItemEvents:) keyEquivalent:@""];
        item.target = self;
        [newMenu addItem:item];
    }
    
    _btnParse.menu = newMenu;
    _txtLen.editable = NO;
    
    myTableView = _iTableView.documentView;
    myTableView.delegate = self;
    myTableView.dataSource = self;
}

- (void)initCapacity
{
    listTitle = [NSMutableArray array];
    listContent = [NSMutableArray array];
    
    NSString *content = @"";
    [_txtContent.documentView setValue:content forKey:@"string"];
    
    NSString *fileName = @"主机协议.plist";
    NSString *dirPath = [[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent];
    dirPath = [dirPath stringByAppendingPathComponent:@"Downloads"];
    NSString *path = [dirPath stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@""];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        [data writeToFile:path atomically:YES];
    }
}

#pragma mark - --------NSTableView------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSInteger rowCount = listContent.count;
    
    return rowCount;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 20.0f;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTextFieldCell *textCell = [tableColumn dataCellForRow:row];
    if (!textCell) {
        textCell = [[NSTextFieldCell alloc] initTextCell:@"cell"];
        textCell.importsGraphics = YES;
        textCell.allowsEditingTextAttributes = YES;
    }
    
    if ([tableColumn.title isEqualToString:@"value"]) {
        
        textCell.textColor = textColor ?: [NSColor blueColor];
        if (listContent.count > row) {
            NSString *title = [listContent objectAtIndex:row];
            textCell.stringValue = title;
        }
        
        NSArray *listMenu = @[@"复制数据"];
        NSMenu *newMenu = [[NSMenu alloc] init];
        for (NSString *title in listMenu) {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(menuItemEvents:) keyEquivalent:@""];
            item.target = self;
            item.tag = row;
            [newMenu addItem:item];
        }
        
        textCell.menu = newMenu;
    }
    else if ([tableColumn.title isEqualToString:@"key"]) {
        if (listTitle.count > row) {
            NSString *title = [listTitle objectAtIndex:row];
            textCell.stringValue = title;
            
            if ([title hasPrefix:@"PT"]) {
                textColor = [NSColor greenColor];
            }else{
                textColor = [NSColor blueColor];
            }
        }
    }
    
    return textCell;///Volumes/Apple/下载
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    NSString *title = [listContent objectAtIndex:row];
    NSLog(@"%@",title);
    
    return YES;
}

#pragma mark - --------右键菜单事件回调------------------------
- (void)menuItemEvents:(NSMenuItem *)menuItem
{
    NSInteger row = menuItem.tag;
    if (listContent.count >= row) {
        NSString *title = [listContent objectAtIndex:row];
        if (title.length > 0) {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard declareTypes:@[NSStringPboardType] owner:self];
            [pasteboard setString:title forType:NSStringPboardType];
        }
    }
}

- (IBAction)ButtonEvents:(NSButton *)sender
{
    NSTextView *text = _txtContent.documentView;
    text.textColor = [NSColor blackColor];
    NSString *content = text.string;
    content = [content uppercaseString];
    content = [content replaceString:@" " withString:@""];
    if (content.length < 2) {
        [Tools alertWithMessage:@"解析错误" informative:@"请输入有效的数据" sheetHandler:nil];
        return;
    }
    
    _txtLen.stringValue = [NSString stringWithFormat:@"%02ld",(long)content.length];
    
    [listContent removeAllObjects];
    [listTitle removeAllObjects];
    
    NSString *dirPath = [[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent];
    dirPath = [dirPath stringByAppendingPathComponent:@"Downloads"];
    NSString *path = [dirPath stringByAppendingPathComponent:@"主机协议.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    int totalLen = (int)content.length;
    int len = 0;
    
    NSArray *listLockHead = @[@"A2",@"E2",@"EB",@"ED",@"EE",@"EF",@"FE"];
    NSString *head = [content substringToIndex:2];
    if ([head hasPrefix:@"DD"]) {
        NSArray *list = [dic objectForKey:head];
        NSString *SumCRC = nil;
        for (NSDictionary *dic1 in list) {
            NSString *key = dic1.allKeys.lastObject;
            if ([key isEqualToString:@"content"]) {
                NSString *rangeStr = [dic1 objectForKey:@"range"];
                NSRange range = NSRangeFromString(rangeStr);
                range = NSMakeRange(range.location, content.length+range.length);
                SumCRC = [content substringWithRange:NSMakeRange(content.length-2, 2)];
                
                content = [content substringWithRange:NSMakeRange(16, content.length-18)];
                break;
            }
            int currentLen = [dic1.allValues.lastObject intValue];
            if (currentLen == 0) {
                currentLen = totalLen - len;
            }
            else if (currentLen < 0) {
                len = totalLen + currentLen;
                currentLen = -currentLen;
            }
            NSString *ptHead = [content substringWithRange:NSMakeRange(len, currentLen)];
            [listContent addObject:ptHead];
            [listTitle addObject:key];
            
            len = len + currentLen;
        }
        
        NSDictionary *dicLock = [dic objectForKey:@"Lock"];
        [self dataLockParse:content mode:dicLock];
        
        [listContent addObject:SumCRC];
        [listTitle addObject:@"PT校验码"];
    }
    else if ([listLockHead containsObject:head]) {
        NSDictionary *dicLock = [dic objectForKey:@"Lock"];
        [self dataLockParse:content mode:dicLock];
    }else{
        [self dataParse:content mode:dic];
    }
    
    [myTableView reloadData];
}

- (void)dataParse:(NSString *)content mode:(NSDictionary *)dic
{
    NSString *head = [content substringToIndex:2];
    if ([head hasPrefix:@"A4"] || [head hasPrefix:@"E4"]) {
        head = [head stringByAppendingFormat:@"-%ld",content.length];
    }
    
    NSArray *list = [dic objectForKey:head];
    int len = 0;
    for (NSDictionary *dicValue in list) {
        int currentLen = [dicValue.allValues.lastObject intValue];
        if (currentLen < 0) {
            currentLen = -currentLen;
        }
        len = len + currentLen;
    }
    
    int totalLen = (int)content.length;
    if (content.length < len) {
        [Tools alertWithMessage:@"数据错误" informative:@"请输入正确的数据"];
        //return;
    }
    
    //NSLog(@"%@",[[dic objectForKey:@"A0"] customDescription]);
    //NSLog(@"%d",len);
    
    len = 0;
    for (NSDictionary *dicValue in list) {
        int currentLen = [dicValue.allValues.lastObject intValue];
        NSString *key = dicValue.allKeys.lastObject;
        if (currentLen == 0) {
            currentLen = totalLen - len;
        }
        else if (currentLen < 0) {
            len = totalLen + currentLen;
            currentLen = -currentLen;
        }
        
        if (len + currentLen > content.length) {
            break;
        }
        
        NSString *ptHead = [content substringWithRange:NSMakeRange(len, currentLen)];
        [listContent addObject:ptHead];
        [listTitle addObject:key];
        
        len = len + currentLen;
    }
}

- (void)dataLockParse:(NSString *)content mode:(NSDictionary *)dic
{
    int len = 0;
    NSString *head = [content substringToIndex:2];
    NSArray *list = [dic arrayForKey:head];
    NSString *sHead = @"";//二级指令类型
    for (NSDictionary *dicValue in list) {
        int currentLen = 0;
        NSArray *keys = dicValue.allKeys;
        NSString *key = @"";
        if (keys.count == 1) {
            key = keys.firstObject;
        }
        id firstObject = dicValue.allValues.firstObject;
        if ([keys containsObject:@"指令类型"]) {
            currentLen = [firstObject intValue];
            sHead = [content substringWithRange:NSMakeRange(len, currentLen)];
        }
        else if ([keys containsObject:sHead]) {
            key = sHead;
            NSArray *sList = [dicValue arrayForKey:sHead];
            for (NSDictionary *sDicValue in sList) {
                currentLen = [sDicValue.allValues.lastObject intValue];
                NSString *sKey = sDicValue.allKeys.firstObject;
                
                NSString *sValue = [content substringWithRange:NSMakeRange(len, currentLen)];
                [listContent addObject:sValue];
                [listTitle addObject:sKey];
                
                len = len + currentLen;
            }
            continue;
        }else{
            if ([firstObject respondsToSelector:@selector(intValue)]) {
                currentLen = [firstObject intValue];
            }
        }
        
        if (currentLen < 0) {
            len = (int)content.length-4;
            currentLen = -currentLen;
        }
        
        NSString *value = [content substringWithRange:NSMakeRange(len, currentLen)];
        [listContent addObject:value];
        [listTitle addObject:key];
        
        len = len + currentLen;
    }
}

@end
