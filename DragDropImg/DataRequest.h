//
//  DataRequest.h
//  DragDropImg
//
//  Created by xy on 2017/12/14.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataRequestDelegate <NSObject>

- (void)downloadToProgress:(CGFloat)progress rate:(CGFloat)rate;

@end

@interface DataRequest : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) int64_t totalLength;
@property (nonatomic, strong) NSURLSession *session; // 会话
@property (nonatomic, strong) NSURLSessionTask *myDataTask; // 请求任务


- (void)startRequest;
- (void)resume;
- (void)suspend;
- (void)cancel;

@end
