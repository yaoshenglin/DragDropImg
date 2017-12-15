//
//  MyHttpRequest.h
//  DragDropImg
//
//  Created by xy on 2017/12/13.
//  Copyright © 2017年 xy. All rights reserved.
//

#define k_action @"api_V2"                      //默认动作根目录
#define k_host @"https://api.happyeasy.cc"      //http://121.201.17.130:8100
#define k_res_host @"http://res.happyeasy.cc"   //http://res.weicontrol.cn

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
- (void)stopRequest;
- (void)cancel;

@end
