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
    text.textColor = [NSColor blackColor];
    NSString *content = text.string;
    if (content.length < 2) {
        [Tools alertWithMessage:@"解析错误" informative:@"请输入有效的数据" sheetHandler:nil];
        return;
    }
    
    [listContent removeAllObjects];
    [listTitle removeAllObjects];
    
    NSString *head = [content substringToIndex:2];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"主机协议.plist" ofType:@""];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *list = [dic objectForKey:head];
    int len = 0;
    for (NSDictionary *dic1 in list) {
        int currentLen = [dic1.allValues.lastObject intValue];
        if (currentLen < 0) {
            currentLen = -currentLen;
        }
        len = len + currentLen;
    }
    
    int totalLen = len;
    if (content.length < totalLen) {
        [Tools alertWithMessage:@"数据错误" informative:@"请输入正确的数据"];
        return;
    }
    
    //NSLog(@"%@",[[dic objectForKey:@"A0"] customDescription]);
    //NSLog(@"%d",len);
    
    len = 0;
    for (NSDictionary *dic1 in list) {
        int currentLen = [dic1.allValues.lastObject intValue];
        NSString *value = dic1.allKeys.lastObject;
        if (currentLen == 0) {
            currentLen = totalLen - len;
        }
        else if (currentLen < 0) {
            len = (int)content.length + currentLen;
            currentLen = -currentLen;
        }
        NSString *ptHead = [content substringWithRange:NSMakeRange(len, currentLen)];
        [listContent addObject:ptHead];
        [listTitle addObject:value];
        
        len = len + currentLen;
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
        
        if ([content hasPrefix:@"D3"]) {
            if (content.length < 34) {
                [Tools alertWithMessage:@"数据错误" informative:@"请输入正确的数据"];
                return;
            }
            
            NSString *slave = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:slave];
            [listTitle addObject:@"从机ID"];
            
            NSString *ErrType = [content substringWithRange:NSMakeRange(22, 2)];
            [listContent addObject:ErrType];
            [listTitle addObject:@"错误类型"];
        }
        else if ([content hasPrefix:@"E0"]) {
            NSString *slave = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:slave];
            [listTitle addObject:@"从机ID"];
            
            NSString *index = [content substringWithRange:NSMakeRange(22, 2)];
            [listContent addObject:index];
            [listTitle addObject:@"从机开关索引"];
        }
        else if ([content hasPrefix:@"E1"]) {
            NSString *slave = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:slave];
            [listTitle addObject:@"从机ID"];
            
            NSString *index = [content substringWithRange:NSMakeRange(22, 2)];
            [listContent addObject:index];
            [listTitle addObject:@"从机开关索引"];
            
            NSString *action = [content substringWithRange:NSMakeRange(28, 2)];
            [listContent addObject:action];
            [listTitle addObject:@"动作标记"];
            
            NSString *range = [content substringWithRange:NSMakeRange(36, 4)];
            [listContent addObject:range];
            [listTitle addObject:@"总动作量程"];
            
            NSString *per = [content substringWithRange:NSMakeRange(40, 2)];
            [listContent addObject:per];
            [listTitle addObject:@"百分值"];
        }
        else if ([content hasPrefix:@"E4"] && content.length == 46) {
            NSString *slave = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:slave];
            [listTitle addObject:@"从机ID"];
            
            NSString *index = [content substringWithRange:NSMakeRange(22, 6)];
            [listContent addObject:index];
            [listTitle addObject:@"从机开关索引"];
            
            NSString *type = [content substringWithRange:NSMakeRange(28, 2)];
            [listContent addObject:type];
            [listTitle addObject:@"动作标记"];
            
            NSString *Version = [content substringWithRange:NSMakeRange(30, 4)];
            [listContent addObject:Version];
            [listTitle addObject:@"固件版本号"];
            
            NSString *range = [content substringWithRange:NSMakeRange(36, 4)];
            [listContent addObject:range];
            [listTitle addObject:@"总动作量程"];
            
            NSString *per = [content substringWithRange:NSMakeRange(40, 2)];
            [listContent addObject:per];
            [listTitle addObject:@"百分值"];
        }
        else if ([content hasPrefix:@"E4"] && content.length == 34) {
            //读取门锁信息
            NSString *slave = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:slave];
            [listTitle addObject:@"从机ID"];
            
            NSString *power = [content substringWithRange:NSMakeRange(22, 2)];
            [listContent addObject:power];
            [listTitle addObject:@"电量值"];
            
            NSString *type = [content substringWithRange:NSMakeRange(28, 2)];
            [listContent addObject:type];
            [listTitle addObject:@"动作标记"];
            
            NSString *Version = [content substringWithRange:NSMakeRange(30, 4)];
            [listContent addObject:Version];
            [listTitle addObject:@"固件版本号"];
        }
        else if ([content hasPrefix:@"E3"]) {
            //开锁
            NSString *slave = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:slave];
            [listTitle addObject:@"从机ID"];
            
            NSString *power = [content substringWithRange:NSMakeRange(22, 2)];
            [listContent addObject:power];
            [listTitle addObject:@"电量值"];
            
            NSString *type = [content substringWithRange:NSMakeRange(24, 2)];
            [listContent addObject:type];
            [listTitle addObject:@"动作标记"];
            
            NSString *Version = [content substringWithRange:NSMakeRange(26, 4)];
            [listContent addObject:Version];
            [listTitle addObject:@"固件版本号"];
            
            NSString *safeCode = [content substringWithRange:NSMakeRange(30, 6)];
            [listContent addObject:safeCode];
            [listTitle addObject:@"安全码"];
        }
        else if ([content hasPrefix:@"E6"]) {
            //主机操作指令
            NSString *HostName = [content substringWithRange:NSMakeRange(14, 4)];
            [listContent addObject:HostName];
            [listTitle addObject:@"主机类型代号"];
            
            NSString *HardWareVersion = [content substringWithRange:NSMakeRange(18, 4)];
            [listContent addObject:HardWareVersion];
            [listTitle addObject:@"硬件固件内部版本号"];
            
            NSString *SoftWareVersion = [content substringWithRange:NSMakeRange(22, 4)];
            [listContent addObject:SoftWareVersion];
            [listTitle addObject:@"硬件固件显示版本号"];
            
            NSString *WorkTime = [content substringWithRange:NSMakeRange(26, 4)];
            [listContent addObject:WorkTime];
            [listTitle addObject:@"主机工作时长"];
            
            NSString *IP = [content substringWithRange:NSMakeRange(30, 8)];
            [listContent addObject:IP];
            [listTitle addObject:@"远程IP地址"];
            
            NSString *Port = [content substringWithRange:NSMakeRange(38, 4)];
            [listContent addObject:Port];
            [listTitle addObject:@"远程端口"];
            
            NSString *ViewModelName = [content substringWithRange:NSMakeRange(42, 20)];
            [listContent addObject:ViewModelName];
            [listTitle addObject:@"主机型号名称"];
            
            NSString *SubType = [content substringWithRange:NSMakeRange(62, 4)];
            [listContent addObject:SubType];
            [listTitle addObject:@"从属类型"];
        }
        else if ([content hasPrefix:@"EC"]) {
            //读取主机温度
            NSString *tempData = [content substringWithRange:NSMakeRange(14, 4)];
            [listContent addObject:tempData];
            [listTitle addObject:@"主机温度"];
        }
        else if ([content hasPrefix:@"D8"]) {
            //下发学习指令成功
            NSString *other = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:other];
            [listTitle addObject:@"下发学习指令成功"];
        }
        else if ([content hasPrefix:@"E8"]) {
            //收到学习到的数据
            NSString *data = [content substringWithRange:NSMakeRange(14, content.length-18)];
            [listContent addObject:data];
            [listTitle addObject:@"收到学习到的数据"];
        }
        else if ([content hasPrefix:@"D9"]) {
            //执行学习到的红外码成功
            NSString *other = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:other];
            [listTitle addObject:@"执行学习到的红外码成功"];
        }
        else if ([content hasPrefix:@"EF"]) {
            //红外码库数据发射指令
            NSString *other = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:other];
            [listTitle addObject:@"执行红外码库数据发射指令成功"];
        }
        else if ([content hasPrefix:@"D5"]) {
            //下发红外配置指令返回成功
            NSString *other = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:other];
            [listTitle addObject:@"下发指令返回成功"];
        }
        else if ([content hasPrefix:@"E5"]) {
            //收到红外智能匹配数据
            NSString *other = [content substringWithRange:NSMakeRange(14, content.length-4)];
            [listContent addObject:other];
            [listTitle addObject:@"收到红外智能匹配数据"];
        }
        
        NSString *CRC = [content substringWithRange:NSMakeRange(content.length-4, 4)];
        [listContent addObject:CRC];
        [listTitle addObject:@"校验码"];
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
        
        if ([content hasPrefix:@"A4"] && content.length == 32) {
            NSString *slave = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:slave];
            [listTitle addObject:@"从机ID"];
            
            NSString *safeCode = [content substringWithRange:NSMakeRange(22, 2)];
            [listContent addObject:safeCode];
            [listTitle addObject:@"安全码"];
        }
        else if ([content hasPrefix:@"A0"] || [content hasPrefix:@"A4"]) {
            NSString *slave = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:slave];
            [listTitle addObject:@"从机ID"];
            
            NSString *Flag = [content substringWithRange:NSMakeRange(22, 2)];
            [listContent addObject:Flag];
            [listTitle addObject:@"是否跳转"];
            
            NSString *index = [content substringWithRange:NSMakeRange(24, 2)];
            [listContent addObject:index];
            [listTitle addObject:@"从机开关索引"];
            
            NSString *ForwardID = [content substringWithRange:NSMakeRange(26, 8)];
            [listContent addObject:ForwardID];
            [listTitle addObject:@"转发从机ID"];
        }
        else if ([content hasPrefix:@"A1"]) {
            NSString *slave = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:slave];
            [listTitle addObject:@"从机ID"];
            
            NSString *Flag = [content substringWithRange:NSMakeRange(22, 2)];
            [listContent addObject:Flag];
            [listTitle addObject:@"是否跳转"];
            
            NSString *index = [content substringWithRange:NSMakeRange(24, 2)];
            [listContent addObject:index];
            [listTitle addObject:@"从机开关索引"];
            
            NSString *ForwardID = [content substringWithRange:NSMakeRange(26, 8)];
            [listContent addObject:ForwardID];
            [listTitle addObject:@"转发从机ID"];
            
            NSString *action = [content substringWithRange:NSMakeRange(36, 2)];
            [listContent addObject:action];
            [listTitle addObject:@"动作标记"];
            
            NSString *per = [content substringWithRange:NSMakeRange(36, 2)];
            [listContent addObject:per];
            [listTitle addObject:@"百分值"];
        }
        else if ([content hasPrefix:@"A3"]) {
            //开锁
            NSString *slave = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:slave];
            [listTitle addObject:@"从机ID"];
            
            NSString *safeCode = [content substringWithRange:NSMakeRange(22, 6)];
            [listContent addObject:safeCode];
            [listTitle addObject:@"安全码"];
            
            NSString *type = [content substringWithRange:NSMakeRange(28, 8)];
            [listContent addObject:type];
            [listTitle addObject:@"用户ID"];
        }
        else if ([content hasPrefix:@"A6"]) {
            //主机操作指令
            NSString *other = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:other];
            [listTitle addObject:@"读取主机ID号码"];
        }
        else if ([content hasPrefix:@"AB"]) {
            //设置主机型号显示名称、主机从属项目类型标识
            NSString *ViewModelName = [content substringWithRange:NSMakeRange(14, 20)];
            [listContent addObject:ViewModelName];
            [listTitle addObject:@"主机显示名字"];
            
            NSString *SubType = [content substringWithRange:NSMakeRange(34, 4)];
            [listContent addObject:SubType];
            [listTitle addObject:@"从属类型"];
        }
        else if ([content hasPrefix:@"AC"]) {
            //读取主机温度
            NSString *other = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:other];
            [listTitle addObject:@"读取主机温度"];
        }
        else if ([content hasPrefix:@"A8"]) {
            //执行学习红外指令
            NSString *other = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:other];
            [listTitle addObject:@"执行学习红外指令"];
        }
        else if ([content hasPrefix:@"C8"]) {
            //取消正在等待学习的指令
            NSString *other = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:other];
            [listTitle addObject:@"取消红外学习指令"];
        }
        else if ([content hasPrefix:@"A9"]) {
            //执行学习到的红外码
            NSString *Flag = [content substringWithRange:NSMakeRange(14, 2)];
            [listContent addObject:Flag];
            [listTitle addObject:@"是否跳转"];
            
            NSString *ForwardID = [content substringWithRange:NSMakeRange(16, 8)];
            [listContent addObject:ForwardID];
            [listTitle addObject:@"转发从机ID"];
            
            NSString *data = [content substringWithRange:NSMakeRange(24, content.length-28)];
            [listContent addObject:data];
            [listTitle addObject:@"学习的红外数据"];
        }
        else if ([content hasPrefix:@"DF"]) {
            //红外码库数据发射指令
            NSString *Flag = [content substringWithRange:NSMakeRange(14, 2)];
            [listContent addObject:Flag];
            [listTitle addObject:@"是否跳转"];
            
            NSString *ForwardID = [content substringWithRange:NSMakeRange(16, 8)];
            [listContent addObject:ForwardID];
            [listTitle addObject:@"转发从机ID"];
            
            NSString *data = [content substringWithRange:NSMakeRange(24, content.length-28)];
            [listContent addObject:data];
            [listTitle addObject:@"码库数据"];
        }
        else if ([content hasPrefix:@"A5"]) {
            //红外智能配置数据指令
            NSString *other = [content substringWithRange:NSMakeRange(14, 8)];
            [listContent addObject:other];
            [listTitle addObject:@"红外智能匹配指令"];
        }
        
        NSString *CRC = [content substringWithRange:NSMakeRange(content.length-4, 4)];
        [listContent addObject:CRC];
        [listTitle addObject:@"校验码"];
    }
}

@end
