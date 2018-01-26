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
    
    myTableView = _iTableView.documentView;
    myTableView.delegate = self;
    myTableView.dataSource = self;
}

- (void)initCapacity
{
    listTitle = [NSMutableArray array];
    listContent = [NSMutableArray array];
    
    NSString *content = @"DD0AA5A1DA34FE18A223122228D9C8C104000000000000000000874DAC";
    [_txtContent.documentView setValue:content forKey:@"string"];
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

//- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    NSTextFieldCell *textCell = [tableColumn dataCellForRow:row];
//    if (!textCell) {
//        textCell = [[NSTextFieldCell alloc] initTextCell:@"cell"];
//        textCell.importsGraphics = YES;
//        textCell.allowsEditingTextAttributes = YES;
//    }
//    
//    if ([tableColumn.title isEqualToString:@"value"]) {
//        NSTableCellView *cellView = [tableView viewAtColumn:1 row:row makeIfNecessary:YES];
//        if ([[tableColumn dataCellForRow:row] isEqual:cellView]) {
//            NSLog(@"OK");
//        }else{
//            NSTableRowView *rowView = [tableView rowViewAtRow:row makeIfNecessary:YES];
//            NSLog(@"%@",[tableColumn dataCellForRow:row]);
//            NSLog(@"%@",tableColumn.identifier);
//            NSLog(@"%@",rowView);
//        }
//        NSString *title = [listContent objectAtIndex:row];
//        textCell.title = title;
//        cellView.textField.stringValue = title;
//    }
//    else if ([tableColumn.title isEqualToString:@"key"]) {
//        NSTableCellView *cellView = [tableView viewAtColumn:0 row:row makeIfNecessary:YES];
//        NSString *title = [NSString stringWithFormat:@"%ld",row+1];
//        cellView.textField.stringValue = title;
//    }
//    
//    return textCell;///Volumes/Apple/下载
//}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTextFieldCell *textCell = [tableColumn dataCellForRow:row];
    if (!textCell) {
        textCell = [[NSTextFieldCell alloc] initTextCell:@"cell"];
        textCell.importsGraphics = YES;
        textCell.allowsEditingTextAttributes = YES;
    }
    
    if ([tableColumn.title isEqualToString:@"value"]) {
        
        textCell.textColor = [NSColor blueColor];
        if (listContent.count > row) {
            NSString *title = [listContent objectAtIndex:row];
            textCell.stringValue = title;
        }
    }
    else if ([tableColumn.title isEqualToString:@"key"]) {
        if (listTitle.count > row) {
            NSString *title = [listTitle objectAtIndex:row];
            textCell.stringValue = title;
        }
    }
    
    return textCell;///Volumes/Apple/下载
}

//- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    NSString *identifier = [tableColumn identifier];
//    NSTextFieldCell *textCell = cell;
//    textCell.allowsEditingTextAttributes = YES;
//    NSString *title = [listContent objectAtIndex:row];
//    [textCell setTitle:title];
//    if ([identifier isEqualToString:@"name"]) {
//        [textCell setTitle:@"A"];
//    }
//    else if ([identifier isEqualToString:@"id"])
//    {
//        [textCell setTitle:@"B"];
//    }
//}

//- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    NSCell *cell = (NSCell *)[tableView viewAtColumn:0 row:row makeIfNecessary:YES];
//    if (!cell) {
//        NSString *title = [NSString stringWithFormat:@"%ld",row+1];
//        cell = [[NSCell alloc] initTextCell:title];
//        cell.stringValue = title;
//    }
//    return cell;
//}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    NSString *title = [listContent objectAtIndex:row];
    NSLog(@"%@",title);
    
    return YES;
}

#pragma mark - --------右键菜单事件回调------------------------
- (void)menuItemEvents:(NSMenuItem *)menuItem
{
    _btnParse.title = menuItem.title;
    if ([menuItem.title isEqualToString:@"解析接收数据"]) {
        _btnParse.tag = 1;
    }
    else if ([menuItem.title isEqualToString:@"解析发送数据"]) {
        _btnParse.tag = 2;
    }
}

- (IBAction)ButtonEvents:(NSButton *)sender
{
    NSTextView *text = _txtContent.documentView;
    NSString *content = text.string;
    if (content.length < 2) {
        [Tools alertWithMessage:@"解析错误" informative:@"请输入有效的数据" sheetHandler:nil];
        return;
    }
    if (sender.tag == 1) {
        [self dataReceiveParse:content];
    }
    else if (sender.tag == 2) {
        _btnParse.tag = 2;
        [self dataSendParse:content];
    }
    
    [myTableView reloadData];
}

- (void)dataReceiveParse:(NSString *)content
{
    [listContent removeAllObjects];
    [listTitle removeAllObjects];
    
    if (content.length < 22) {
        [Tools alertWithMessage:@"数据错误" informative:@"请输入正确的数据"];
        return;
    }
    
    if ([content hasPrefix:@"DD"]) {
        NSString *ptHead = [content substringToIndex:2];
        [listContent addObject:ptHead];
        [listTitle addObject:@"透传指令头"];
        
        NSString *targetFlag = [content substringWithRange:NSMakeRange(2, 2)];
        [listContent addObject:targetFlag];
        [listTitle addObject:@"透传模式"];
        
        NSString *host = [content substringWithRange:NSMakeRange(4, 12)];
        [listContent addObject:host];
        [listTitle addObject:@"透传主机ID"];
        
        content = [content substringFromIndex:16];
        if ([content hasPrefix:@"E2"]) {
            NSString *head = [content substringToIndex:2];
            [listContent addObject:head];
            [listTitle addObject:@"指令帧头"];
            
            NSString *slave = [content substringWithRange:NSMakeRange(2, 8)];
            [listContent addObject:slave];
            [listTitle addObject:@"门锁ID"];
            
            NSString *safeCode = [content substringWithRange:NSMakeRange(10, 6)];
            [listContent addObject:safeCode];
            [listTitle addObject:@"安全码"];
            
            NSString *type = [content substringWithRange:NSMakeRange(16, 2)];
            [listContent addObject:type];
            [listTitle addObject:@"指令类型"];
            
            NSArray *titles = @[@"开锁认证方式",@"门锁功能开关",@"系统电量管理模式",@"访客密码有效状态",@"最大用户数"];
            for (int i=0; i<titles.count; i++) {
                NSString *title = [titles objectAtIndex:i];
                NSString *CM = [content substringWithRange:NSMakeRange(18+i*2, 2)];
                [listContent addObject:CM];
                [listTitle addObject:title];
            }
            
            NSString *ConfigParms = [content substringWithRange:NSMakeRange(28, 8)];
            [listContent addObject:ConfigParms];
            [listTitle addObject:@"配置参数"];
            
            NSString *CRC = [content substringWithRange:NSMakeRange(content.length-6, 4)];
            [listContent addObject:CRC];
            [listTitle addObject:@"校验码"];
        }
        
        NSString *SumCRC = [content substringWithRange:NSMakeRange(content.length-2, 2)];
        [listContent addObject:SumCRC];
        [listTitle addObject:@"透传校验码"];
    }else{
        NSString *head = [content substringToIndex:2];
        [listContent addObject:head];
        [listTitle addObject:@"指令头"];
        
        NSString *host = [content substringWithRange:NSMakeRange(2, 12)];
        [listContent addObject:host];
        [listTitle addObject:@"主机ID"];
        
        NSString *slave = [content substringWithRange:NSMakeRange(14, 8)];
        [listContent addObject:slave];
        [listTitle addObject:@"从机ID"];
        
        if ([content hasPrefix:@"D3"]) {
            if (content.length < 34) {
                [Tools alertWithMessage:@"数据错误" informative:@"请输入正确的数据"];
                return;
            }
            
            NSString *ErrType = [content substringWithRange:NSMakeRange(22, 2)];
            [listContent addObject:ErrType];
            [listTitle addObject:@"错误类型"];
            
            NSString *CRC = [content substringWithRange:NSMakeRange(content.length-4, 4)];
            [listContent addObject:CRC];
            [listTitle addObject:@"校验码"];
        }
    }
}

- (void)dataSendParse:(NSString *)content
{
    [listContent removeAllObjects];
    [listTitle removeAllObjects];
    
    if (content.length < 22) {
        [Tools alertWithMessage:@"数据错误" informative:@"请输入正确的数据"];
        return;
    }
    
    if ([content hasPrefix:@"DD"]) {
        NSString *ptHead = [content substringToIndex:2];
        [listContent addObject:ptHead];
        [listTitle addObject:@"透传指令头"];
        
        NSString *targetFlag = [content substringWithRange:NSMakeRange(2, 2)];
        [listContent addObject:targetFlag];
        [listTitle addObject:@"透传模式"];
        
        NSString *host = [content substringWithRange:NSMakeRange(4, 12)];
        [listContent addObject:host];
        [listTitle addObject:@"透传主机ID"];
        
        content = [content substringFromIndex:16];
        if ([content hasPrefix:@"A2"]) {
            NSString *head = [content substringToIndex:2];
            [listContent addObject:head];
            [listTitle addObject:@"指令帧头"];
            
            NSString *slave = [content substringWithRange:NSMakeRange(2, 8)];
            [listContent addObject:slave];
            [listTitle addObject:@"门锁ID"];
            
            NSString *safeCode = [content substringWithRange:NSMakeRange(10, 6)];
            [listContent addObject:safeCode];
            [listTitle addObject:@"安全码"];
            
            NSString *type = [content substringWithRange:NSMakeRange(16, 2)];
            [listContent addObject:type];
            [listTitle addObject:@"指令类型"];
            
            NSArray *titles = @[@"开锁认证方式",@"门锁功能开关",@"系统电量管理模式",@"访客密码有效状态",@"最大用户数"];
            for (int i=0; i<titles.count; i++) {
                NSString *title = [titles objectAtIndex:i];
                NSString *CM = [content substringWithRange:NSMakeRange(18+i*2, 2)];
                [listContent addObject:CM];
                [listTitle addObject:title];
            }
            
            NSString *ConfigParms = [content substringWithRange:NSMakeRange(28, 8)];
            [listContent addObject:ConfigParms];
            [listTitle addObject:@"配置参数"];
            
            NSString *CRC = [content substringWithRange:NSMakeRange(content.length-6, 4)];
            [listContent addObject:CRC];
            [listTitle addObject:@"校验码"];
        }
        
        NSString *SumCRC = [content substringWithRange:NSMakeRange(content.length-2, 2)];
        [listContent addObject:SumCRC];
        [listTitle addObject:@"透传校验码"];
    }else{
        NSString *head = [content substringToIndex:2];
        [listContent addObject:head];
        [listTitle addObject:@"指令头"];
        
        NSString *host = [content substringWithRange:NSMakeRange(2, 12)];
        [listContent addObject:host];
        [listTitle addObject:@"主机ID"];
        
        NSString *slave = [content substringWithRange:NSMakeRange(14, 8)];
        [listContent addObject:slave];
        [listTitle addObject:@"从机ID"];
        
        if ([content hasPrefix:@"D3"]) {
            if (content.length < 34) {
                [Tools alertWithMessage:@"数据错误" informative:@"请输入正确的数据"];
                return;
            }
            
            NSString *ErrType = [content substringWithRange:NSMakeRange(22, 2)];
            [listContent addObject:ErrType];
            [listTitle addObject:@"错误类型"];
            
            NSString *CRC = [content substringWithRange:NSMakeRange(content.length-4, 4)];
            [listContent addObject:CRC];
            [listTitle addObject:@"校验码"];
        }
    }
}

@end
