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
@property (nonatomic, retain) NSMutableArray *dataSource;
@property (nonatomic, retain) NSMutableDictionary *dicData;
@property (nonatomic, retain) NSDictionary *userInfo;

+ (PackageXMLParser *)xmlWithData:(NSData *)data;
- (id)initWithDelegate:(id)delegate;
- (id)initWithData:(NSData *)data;
- (void)parse;

@end
