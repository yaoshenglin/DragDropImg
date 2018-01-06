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
        _isShowResult = YES;
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
        _dataSource = [NSMutableArray array];
        _dataAttributeDict = [NSMutableArray array];
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
    
    if (elementName && attributeDict) {
        [_dataAttributeDict addObject:@{elementName:attributeDict}];//头部区域
    }
    
    NSString *httpEquiv = attributeDict[@"http-equiv"];
    httpEquiv = [httpEquiv lowercaseString];
    if ([httpEquiv isEqualToString:@"content-type"]) {
        NSString *content = attributeDict[@"content"];//数据类型、编码
        if (content.length > 0) {
            _userInfo = @{httpEquiv:content};
        }
    }
    
    //不同行的分别存储
    if (currentLine != parser.lineNumber || !currentValue) {
        currentLine = parser.lineNumber;
        currentValue = [NSMutableString string];
    }
    
    currentRootElement = dicElement[@(parser.lineNumber)];//获取当前行的解析关键字
    if (!currentRootElement && elementName.length) {
        //如果是新的行数
        currentRootElement = elementName;
        [dicElement setObject:elementName forKey:@(parser.lineNumber)];//对应行数和关键字
    }
}

// 当解析器找到开始标记和结束标记之间的字符时，调用这个方法解析当前节点的所有字符
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_isShowLog) {
        long lineNumber = parser.lineNumber;
        long columnNumber = parser.columnNumber;
        NSLog(@"foundCharacters, %@,%ld,%ld",string,lineNumber,columnNumber);
    }
    if (string.length) {
        [currentValue appendString:string];//累加
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
    
    if (namespaceURI.length || qName.length) {
        //NSLog(@"namespaceURI = %@,qName = %@",namespaceURI,qName);
    }
    
    if (currentValue.length && currentRootElement.length) {
        NSDictionary *dic = @{currentRootElement:currentValue};
        if (![_dataSource containsObject:dic]) {
            [_dataSource addObject:dic];
        }
    }
    
    if (currentLine != parser.lineNumber) {
        currentValue = nil;//行数已经改变时置空
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
    NSArray *list = _dataSource;
    if (!list.count) {
        list = _dataAttributeDict;
    }
    NSLog(@"%ld",(long)list.count);
    NSMutableString *string = [NSMutableString string];
    for (NSDictionary *dic in list) {
        NSString *key = dic.allKeys.firstObject;
        NSString *value = dic[key];
        [string appendFormat:@"\n%@ = %@",key,[value customDescription]];
        [_dicData setObject:value forKey:key];
    }
    
    if (_isShowResult) {
        NSLog(@"%@",string);
    }
}

@end

@implementation PackageXMLParser (Extension)

+ (NSString *)getBodyWithData:(NSData *)data
{
    // 创建解析器
    PackageXMLParser *xmlParser = [PackageXMLParser xmlWithData:data];
    //xmlParser.isShowLog = YES;
    [xmlParser parse];
    
    NSString *result = [xmlParser.dataSource.lastObject allValues].firstObject;
    return result;
}

+ (NSString *)getBodyWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
    NSString *string = [[NSString alloc] initWithData:data encoding:encoding];
    data = [string dataUsingEncoding:NSUTF8StringEncoding];
    PackageXMLParser *xmlParser = [PackageXMLParser xmlWithData:data];
    //xmlParser.isShowLog = YES;
    [xmlParser parse];
    
    NSString *result = [xmlParser.dataSource.lastObject allValues].firstObject;
    return result;
}

+ (NSString *)getBodyWithString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    PackageXMLParser *xmlParser = [PackageXMLParser xmlWithData:data];
    //xmlParser.isShowLog = YES;
    [xmlParser parse];
    
    NSString *result = [xmlParser.dataSource.lastObject allValues].firstObject;
    return result;
}

@end
