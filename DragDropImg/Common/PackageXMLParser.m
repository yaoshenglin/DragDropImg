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
 *  开始解析进行回调的Delegate Function
 *
 *  @param parser 执行回调方法的NSXMLParser方法
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
 *  准备解析结点进行的回调
 *  在此处可以获取每个xml结点所传递的信息，如(xmlns--类似命名空间)
 *
 *  @param parser        执行回调方法的NSXMLParser对象
 *  @param elementName   结点的字符串描述(如name..)
 *  @param namespaceURI  命名空间的统一资源标志符字符串描述
 *  @param qName         命名空间的字符串描述
 *  @param attributeDict 参数字典
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

/**
 *  获得首尾结点间内容信息的内容
 *
 *  @param parser 执行回调方法的NSXMLParse对象
 *  @param string 结点间的内容
 *  如果结点之间的内容是结点段，那么返回的string首字符为unichar类型的‘\n’
 *  如果不是结点段，那么直接返回之间的信息内容
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_isShowLog) {
        long lineNumber = parser.lineNumber;
        long columnNumber = parser.columnNumber;
        NSLog(@"foundCharacters, %@,%ld,%ld,%@",string,lineNumber,columnNumber,currentRootElement);
        
        if ([string characterAtIndex:0] != '\n') {
            NSLog(@"-----包含其他结点的结点-----");
        }
    }
    if (string.length) {
        [currentValue appendString:string];//累加
    }
}

/**
 *  某个结点解析完毕进行的回调
 *
 *  @param parser       执行回调方法的NSXMLParse对象
 *  @param elementName  结点的字符串描述(如name..)
 *  @param namespaceURI 命名空间的统一资源标志符字符串描述
 *  @param qName        命名空间的字符串描述
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
 *  XML解析完成进行的回调
 *
 *  @param parser 执行回调方法的NSXMLParse对象
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"解析结束");
    [self logWithData];
}

/**
 *  解析出现错误的时候调用
 *
 *  @param parser       执行回调方法的NSXMLParse对象
 *  @param parseError   错误描述
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
