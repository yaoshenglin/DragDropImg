//
//  PackageXMLParser.h
//  DragDropImg
//
//  Created by xy on 2017/12/26.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PackageXMLParser : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, assign) BOOL isShowLog;
@property (nonatomic, assign) BOOL isShowResult;
@property (nonatomic, retain) NSMutableArray *dataAttributeDict;//头部区域
@property (nonatomic, retain) NSMutableArray *dataSource;//数据区
@property (nonatomic, retain) NSMutableDictionary *dicData;
@property (nonatomic, retain) NSDictionary *userInfo;

+ (PackageXMLParser *)xmlWithData:(NSData *)data;
- (id)initWithDelegate:(id)delegate;
- (id)initWithData:(NSData *)data;
- (void)parse;

@end

@interface PackageXMLParser (Extension)

+ (NSString *)getBodyWithData:(NSData *)data;
+ (NSString *)getBodyWithData:(NSData *)data forKey:(NSString *)key;
+ (NSString *)getBodyWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
+ (NSString *)getBodyWithString:(NSString *)string;

@end
