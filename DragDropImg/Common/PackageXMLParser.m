//
//  PackageXMLParser.m
//  DragDropImg
//
//  Created by xy on 2017/12/26.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "PackageXMLParser.h"
#import "Tools.h"

@interface PackageXMLParser ()<NSXMLParserDelegate>
{
    NSXMLParser *xmlParser;
    NSString *currentRootElement;
    
    NSMutableArray *dataSource;
    NSMutableString *currentValue;
}

@end

@implementation PackageXMLParser

- (id)init
{
    self = [super init];
    if (self) {
        [self initCapacity];
    }
    
    return self;
}

- (id)initWithDelegate:(id)delegate
{
    self = [self init];
    _delegate = delegate;
    
    return self;
}

- (id)initWithData:(NSData *)data
{
    self = [self init];
    _data = data;
    
    return self;
}

- (void)initCapacity
{
    NSString *path = @"/Users/xy/Library/Developer/Xcode/DerivedData/DragDropImg-bgyaoueutozmwweewybfgccinuzg/Build/Products/Debug/DragDropImg.app/Contents/Downloads/UpdateSceneImg.html";
    self.data = [NSData dataWithContentsOfFile:path];
}

- (void)setData:(NSData *)data
{
    _data = data;
    
    // 创建解析器
    xmlParser = [[NSXMLParser alloc] initWithData:_data];
    // 设置代理
    xmlParser.delegate = self;
}

- (void)parse
{
    [xmlParser parse];
}

#pragma mark - --------NSXMLParser delegate------------------------

/**
 *  解析到文档的开头时会调用
 */
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    //NSLog(@"%@",[parser customDescription]);
}

/**
 *  解析到一个元素的开始就会调用
 *
 *  @param elementName   元素名称
 *  @param attributeDict 属性字典
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"开始标签  %@,%@", elementName,[attributeDict customDescription]);
    if (namespaceURI.length || qName.length) {
        NSLog(@"namespaceURI = %@,qName = %@",namespaceURI,qName);
    }
    
    
    currentValue = [NSMutableString string];
    if (dataSource == nil) {
        dataSource = [NSMutableArray new];
    }
    
    currentRootElement = elementName;
}

// 当解析器找到开始标记和结束标记之间的字符时，调用这个方法解析当前节点的所有字符
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"foundCharacters, %@",string);
    if (string.length) {
        [currentValue appendString:string];
    }
}

/**
 *  解析到一个元素的结束就会调用
 *
 *  @param elementName   元素名称
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSLog(@"didEndElement: %@",elementName);
    if (namespaceURI.length || qName.length) {
        //NSLog(@"namespaceURI = %@,qName = %@",namespaceURI,qName);
    }
    
    if (currentValue && elementName.length) {
        NSDictionary *dic = @{elementName:currentValue};
        [dataSource addObject:dic];
    }
    
    currentValue = nil;
}

/**
 *  解析到文档的结尾时会调用（解析结束）
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"解析结束");
    [self logWithData];
}

/**
 *  解析出现错误的时候调用
 */
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"%@",parseError.localizedDescription);
    [self logWithData];
}

- (void)logWithData
{
    NSLog(@"%ld",(long)dataSource.count);
    NSMutableString *string = [NSMutableString string];
    for (NSDictionary *dic in dataSource) {
        NSString *key = dic.allKeys.firstObject;
        NSString *value = dic[key];
        [string appendFormat:@"\n%@ = %@",key,value];
    }
    
    NSLog(@"%@",string);
}

@end
