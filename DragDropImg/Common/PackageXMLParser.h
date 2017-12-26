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

- (id)initWithDelegate:(id)delegate;
- (id)initWithData:(NSData *)data;
- (void)initCapacity;
- (void)parse;

@end
