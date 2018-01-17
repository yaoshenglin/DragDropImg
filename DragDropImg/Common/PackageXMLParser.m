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
    
    BOOL isUseList;
    int operationType;
    NSInteger currentLine;
    NSMutableDictionary *dicLineElement;
    NSDictionary *dicLineValue;
    NSMutableArray *listElement;
    NSMutableArray *listValue;
    NSString *lastRootElement;
    NSString *currentRootElement;
    NSMutableString *currentValue;
    NSMutableDictionary *lastDic;
    NSMutableDictionary *currentDic;
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
        dicLineElement = [NSMutableDictionary dictionary];
        listElement = [NSMutableArray array];
        listValue = [NSMutableArray array];
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
    long lineNumber = parser.lineNumber;
    if (_isShowLog) {
        NSLog(@"开始标签  %@,%ld,%@", elementName,lineNumber,[attributeDict customDescription]);
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
    if (currentLine != parser.lineNumber) {
        currentLine = parser.lineNumber;
        currentValue = [[NSMutableString alloc] init];
        
        [dicLineElement setObject:elementName forKey:@(currentLine)];
        
        if (![currentRootElement isEqualToString:elementName]) {
            [listElement addObject:elementName];
            if (!isUseList && [listElement containsObject:currentRootElement]) {
                lastRootElement = currentRootElement;
            }
            currentRootElement = elementName;
        }
    }
    
    operationType = 1;
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
    BOOL isList = [string characterAtIndex:0] != '\n';
    if (_isShowLog) {
        long lineNumber = parser.lineNumber;
        long columnNumber = parser.columnNumber;
        long len = string.length;
        NSString *value = [dicLineElement objectForKey:@(parser.lineNumber)];
        NSLog(@"foundCharacters, %@,%ld,%ld,%@,len=%ld",string,lineNumber,columnNumber,value,len);
        
        if (isList) {
            NSLog(@"-----包含其他结点的结点-----");
        }
    }
    if (string.length) {
        [currentValue appendString:string];//累加
    }
    
    if (operationType != 1) {
        operationType = 2;//过滤从结束状态过来的
        return;
    }
    
    if (lastRootElement && ![listElement containsObject:lastRootElement]) {
        return;
    }
    
    currentDic = currentDic ?: _dicData;
    if (isList) {
        isUseList = YES;
        NSMutableArray *list = [lastDic objectForKey:lastRootElement];
        if (!list || [list isKindOfClass:[NSNull class]]) {
            list = [NSMutableArray array];
            [lastDic setObject:list forKey:lastRootElement];
        }
        
        dicLineValue = @{@(currentLine):list};
    }else{
        NSMutableDictionary *dic = [lastDic objectForKey:lastRootElement];
        if (!dic) {
            dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSNull null] forKey:currentRootElement];
            if (lastRootElement) {
                [currentDic setObject:dic forKey:lastRootElement];
            }else{
                currentDic = dic;
                _dicData = dic;
            }
            lastDic = dic;
            dicLineValue = @{@(currentLine):dic};
            [listValue addObject:dic];
        }
        else if ([dic isKindOfClass:[NSNull class]]) {
            dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSNull null] forKey:currentRootElement];
            [currentDic setObject:dic forKey:lastRootElement];
            lastDic = dic;
            dicLineValue = @{@(currentLine):dic};
            [listValue addObject:dic];
        }
        else if ([dic isKindOfClass:[NSDictionary class]]) {
            currentDic = dic;
        }
    }
    
    operationType = 2;
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
    
    id obj = [dicLineValue objectForKey:@(currentLine)];
    if (currentValue.length && currentRootElement.length) {
        NSDictionary *dic = @{currentRootElement:currentValue};
        
        if ([obj isKindOfClass:[NSArray class]]) {
            NSMutableArray *list = obj;
            if (![list containsObject:dic]) {
                [list addObject:dic];
            }
        }
        else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dictionary = obj;
            [dictionary setObject:dic forKey:currentRootElement];
        }
    }
    
    if (currentLine != parser.lineNumber) {
        currentValue = nil;//行数已经改变时置空
    }
    
    if ([lastRootElement isEqualToString:elementName]) {
        isUseList = NO;
    }
    
    if (elementName && [listElement containsObject:elementName]) {
        [listElement removeObject:elementName];
        lastRootElement = listElement.lastObject;
        
        NSDictionary *dic = listValue.lastObject;
        if ([dic isKindOfClass:[NSDictionary class]]) {
            if ([dic.allKeys containsObject:elementName]) {
                [listValue removeLastObject];
            }
        }
        for (id obj in listValue) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                lastDic = obj;
            }
        }
    }
    
    operationType = 3;
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
    NSLog(@"%ld",(long)_dicData.count);
    NSString *string = [_dicData customDescription];
    
    if (_isShowResult) {
        NSLog(@"%@",string);
        NSLog(@"%@",dicLineElement);
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
