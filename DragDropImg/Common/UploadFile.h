//
//  UploadFile.h
//  iFace
//
//  Created by Yin on 15-6-19.
//  Copyright © 2015年 weicontrol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "HTTPRequest.h"

@class UploadFile;
@protocol UploadDelegate <NSObject>

@optional
- (void)sendProgress:(CGFloat)progress;
- (void)receiveProgress:(CGFloat)progress;
- (void)ws:(UploadFile *)iWS sendProgress:(CGFloat)progress;
- (void)ws:(UploadFile *)iWS receiveProgress:(CGFloat)progress;
- (void)wsOK:(UploadFile *)iWS;
- (void)wsFailed:(UploadFile *)iWS;

@end

@interface UploadFile : NSObject

@property (retain, nonatomic) NSString *tag;
@property (retain, nonatomic) NSDictionary *dicTag;//标签

- (HTTPRequest *)run:(NSString *)method body:(NSDictionary *)body delegate:(id)thedelegate;
- (void)setValue:(NSString *)value forHeader:(NSString *)field;
- (void)addValue:(NSString *)value forHeader:(NSString *)field;
- (void)addRequestHeader:(NSDictionary *)dicData;
- (void)addRequestHeader:(NSDictionary *)dicData encoding:(NSStringEncoding)encoding;
- (void)start;
- (void)cancel;

@end
