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
    
    NSInteger currentLine;
    NSMutableString *currentValue;
    NSMutableDictionary *dicElement;
}

@end

@implementation PackageXMLParser

+ (PackageXMLParser *)xmlWithData:(NSData *)data
{
    PackageXMLParser *xmlParser = [[PackageXMLParser alloc] initWithData:data];
    return xmlParser;
}

- (id)init
{
    self = [super init];
    if (self) {
        _isShowLog = NO;
        _dicData = [NSMutableDictionary dictionary];
        dicElement = [NSMutableDictionary dictionary];
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
    self.data = data;
    
    return self;
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
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray new];
    }
}

/**
 *  解析到一个元素的开始就会调用
 *
 *  @param elementName   元素名称
 *  @param attributeDict 属性字典
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (_isShowLog) {
        NSLog(@"开始标签  %@,%@", elementName,[attributeDict customDescription]);
        if (namespaceURI.length || qName.length) {
            NSLog(@"namespaceURI = %@,qName = %@",namespaceURI,qName);
        }
    }
    
    NSString *httpEquiv = attributeDict[@"http-equiv"];
    httpEquiv = [httpEquiv lowercaseString];
    if ([httpEquiv isEqualToString:@"content-type"]) {
        NSString *content = attributeDict[@"content"];//数据类型、编码
        if (content.length > 0) {
            _userInfo = @{httpEquiv:content};
        }
    }
    
    if (currentLine != parser.lineNumber || !currentValue) {
        currentLine = parser.lineNumber;
        currentValue = [NSMutableString string];
    }
    
    currentRootElement = dicElement[@(parser.lineNumber)];
    if (!currentRootElement && elementName.length) {
        currentRootElement = elementName;
        [dicElement setObject:elementName forKey:@(parser.lineNumber)];
    }
}

// 当解析器找到开始标记和结束标记之间的字符时，调用这个方法解析当前节点的所有字符
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_isShowLog) {
        NSLog(@"foundCharacters, %@,%ld,%ld",string,parser.lineNumber,parser.columnNumber);
    }
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
    if (_isShowLog) {
        NSLog(@"didEndElement: %@",elementName);
    }
    
    if (currentLine != parser.lineNumber) {
        currentValue = nil;
    }
    
    if (namespaceURI.length || qName.length) {
        //NSLog(@"namespaceURI = %@,qName = %@",namespaceURI,qName);
    }
    
    if (currentValue.length && currentRootElement.length) {
        NSDictionary *dic = @{currentRootElement:currentValue};
        if (![_dataSource containsObject:dic]) {
            [_dataSource addObject:dic];
        }
    }
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
    NSLog(@"%ld",(long)_dataSource.count);
    NSMutableString *string = [NSMutableString string];
    for (NSDictionary *dic in _dataSource) {
        NSString *key = dic.allKeys.firstObject;
        NSString *value = dic[key];
        [string appendFormat:@"\n%@ = %@",key,value];
        [_dicData setObject:value forKey:key];
    }
    
    NSLog(@"%@",string);
}

@end
