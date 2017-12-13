//
//  MyHttpRequest.h
//  DragDropImg
//
//  Created by xy on 2017/12/13.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyRequestDelegate <NSObject>

- (void)downloadToProgress:(CGFloat)progress rate:(CGFloat)rate;

@end

@interface MyHttpRequest : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) int64_t totalLength;
@property (nonatomic, strong) NSData *resumData; // 续传数据
@property (nonatomic, strong) NSURLSession *session; // 会话
@property (nonatomic, strong) NSURLSessionTask *myDataTask; // 请求任务


- (void)startRequest;

@end
