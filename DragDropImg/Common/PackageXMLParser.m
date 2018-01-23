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
    NSXMLParser *xmlParser;//
    
    BOOL isUseList;//使用数组
    BOOL isNextNode;
    int operationType;//操作类型
    NSInteger currentLine;//当前行
    NSMutableArray *listElement;//关键字集合
    NSMutableArray *listValue;//内容集合
    NSString *lastRootElement;//上一个关键字
    NSString *currentRootElement;//当前关键字
    NSMutableString *currentValue;//当前内容
    NSMutableDictionary *lastDic;//最后一个可用字典
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
    long columnNumber = parser.columnNumber;
    if (_isShowLog) {
        NSLog(@"开始标签  %@,%ld,%ld,%@", elementName,lineNumber,columnNumber,[attributeDict customDescription]);
        if (namespaceURI.length || qName.length) {
            NSLog(@"namespaceURI = %@,qName = %@",namespaceURI,qName);
        }
    }
    
    if (!elementName) {
        return;//节点关键字为空(一般不存在)
    }
    
    if (attributeDict) {
        [_dataAttributeDict addObject:@{elementName:attributeDict}];//头部区域
    }
    
    NSString *httpEquiv = attributeDict[@"http-equiv"];
    httpEquiv = [httpEquiv lowercaseString];
    if ([httpEquiv isEqualToString:@"content-type"]) {
        NSString *content = attributeDict[@"content"];//数据类型、编码0
        if (content.length > 0) {
            _userInfo = @{httpEquiv:content};
        }
    }
    
    if (isNextNode && operationType == 2) {
        //当该结点的内容还没有结束时
        isNextNode = NO;
        operationType = 1;
        return;
    }
    
    //不同行的分别存储
    currentLine = parser.lineNumber;
    currentValue = [[NSMutableString alloc] init];
    
    [listElement addObject:elementName];
    
    if (!isUseList && [listElement containsObject:currentRootElement]) {
        lastRootElement = currentRootElement;
    }
    
    currentRootElement = elementName;//开始
    id obj = [lastDic objectForKey:lastRootElement];
    if (!obj) {
        obj = [@{elementName:[NSMutableDictionary dictionary]} mutableCopy];
        _dicData = obj;
        lastDic = obj;
        [listValue addObject:obj];
    }
    else if ([obj isKindOfClass:[NSArray class]]) {
    }
    else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dicValue = obj;
        [dicValue setObject:[NSMutableDictionary dictionary] forKey:elementName];
        [listValue addObject:dicValue];
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
    isNextNode = isList;
    if (_isShowLog) {
        long lineNumber = parser.lineNumber;
        long columnNumber = parser.columnNumber;
        long len = string.length;
        NSString *value = currentLine == lineNumber ? currentRootElement : @"下一行";
        NSLog(@"foundCharacters, %@,%ld,%ld,%@,len=%ld",string,lineNumber,columnNumber,value,len);
        
        if (isList) {
            NSLog(@"-----包含其他结点的结点-----");
        }
    }
    
    if (isList) {
        isUseList = YES;
        if (string.length) {
            [currentValue appendString:string];//累加
        }
        NSMutableArray *list = [lastDic objectForKey:lastRootElement];
        if (![list isKindOfClass:[NSArray class]]) {
            list = [NSMutableArray array];
            [lastDic setObject:list forKey:lastRootElement];
            [listValue removeLastObject];
        }
        
        if (![list containsObject:@{currentRootElement:currentValue}]) {
            [list addObject:@{currentRootElement:currentValue}];
        }
        
    }else{
        if (lastRootElement && operationType == 1) {
            lastDic = [lastDic objectForKey:lastRootElement];
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
        NSLog(@"didEndElement: %@",elementName);//结束
    }
    
    if (namespaceURI.length || qName.length) {
        //NSLog(@"namespaceURI = %@,qName = %@",namespaceURI,qName);
    }
    
    if (operationType == 1) {
        isUseList = YES;
        NSMutableArray *list = [lastDic objectForKey:lastRootElement];
        if (![list isKindOfClass:[NSArray class]]) {
            list = [NSMutableArray array];
            [lastDic removeObjectForKey:currentRootElement];
            [lastDic setObject:list forKey:lastRootElement];
            //[listValue addObject:list];
            [listValue removeLastObject];
        }
        
        if (currentValue.length && ![list containsObject:@{currentRootElement:currentValue}]) {
            [list addObject:@{currentRootElement:currentValue}];
        }
    }
    
    id obj = [lastDic objectForKey:lastRootElement];
    if (currentValue.length && currentRootElement.length) {
        NSDictionary *dic = @{currentRootElement:currentValue};
        if (operationType == 1) {
            dic = _dataAttributeDict.lastObject;
        }
        
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
    }else{
        if (operationType == 1) {
            NSDictionary *dic = _dataAttributeDict.lastObject;
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
    }
    
    if (currentLine != parser.lineNumber) {
        currentValue = nil;//行数已经改变时置空
    }
    
    if ([lastRootElement isEqualToString:elementName]) {
        isUseList = NO;//结束标志出现时结束数组状态
    }
    
    if (currentValue && ![_dataSource containsObject:currentValue]) {
        [_dataSource addObject:currentValue];//有效值储存到集合中来
    }
    
    if (elementName && [listElement containsObject:elementName]) {
        [listElement removeObject:elementName];
        if (!isUseList) {
            lastRootElement = listElement.lastObject;
        }
        
        NSDictionary *dic = listValue.lastObject;
        if ([dic.allKeys containsObject:elementName]) {
            [listValue removeLastObject];
            for (id obj in listValue) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    lastDic = obj;
                }
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
    NSDictionary *dicHtml = _dicData.allValues.firstObject;
    if (_dicData.count > 1 || ![dicHtml isKindOfClass:[NSDictionary class]]) {
        dicHtml = _dicData;
    }
    NSLog(@"%ld",(long)dicHtml.count);
    NSString *string = [dicHtml customDescription];
    
    if (_isShowResult) {
        NSLog(@"%@",string);
    }
}

- (id)parseData:(id)obj forKey:(NSString *)key
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = obj;
        if (dic[key]) {
            return dic[key];
        }
        for (NSString *key1 in dic) {
            id value = dic[key1];
            if (![value isKindOfClass:[NSString class]]) {
                id obj2 = [self parseData:value forKey:key];
                if (obj2) {
                    return obj2;
                }
            }else{
                continue;
            }
        }
    }
    else if ([obj isKindOfClass:[NSArray class]]) {
        NSArray *list = obj;
        for (id obj1 in list) {
            if (![obj1 isKindOfClass:[NSString class]]) {
                id obj2 = [self parseData:obj1 forKey:key];
                if (obj2) {
                    return obj2;
                }
            }else{
                continue;
            }
        }
    }
    return nil;
}

- (id)parseData:(id)obj string:(NSMutableString *)string
{
    string = string ?: [NSMutableString string];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = obj;
        for (NSString *key1 in dic) {
            id value = dic[key1];
            [self parseData:value string:string];
        }
    }
    else if ([obj isKindOfClass:[NSArray class]]) {
        NSArray *list = obj;
        for (id obj1 in list) {
            [self parseData:obj1 string:string];
        }
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        [string appendString:obj];
    }
    return string;
}

@end

@implementation PackageXMLParser (Extension)

+ (NSString *)getBodyWithData:(NSData *)data
{
    NSString *result = [self getBodyWithData:data forKey:@"body"];
    
    return result;
}

+ (NSString *)getBodyWithData:(NSData *)data forKey:(NSString *)key
{
    // 创建解析器
    PackageXMLParser *xmlParser = [PackageXMLParser xmlWithData:data];
    //xmlParser.isShowLog = YES;
    [xmlParser parse];
    
    id obj = [xmlParser parseData:xmlParser.dicData forKey:key];
    NSString *result = [xmlParser parseData:obj string:nil];
    
    return result;
}

+ (NSString *)getBodyWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
    NSString *string = [[NSString alloc] initWithData:data encoding:encoding];
    data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *result = [self getBodyWithData:data];
    return result;
}

+ (NSString *)getBodyWithString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *result = [self getBodyWithData:data];
    
    return result;
}

@end
