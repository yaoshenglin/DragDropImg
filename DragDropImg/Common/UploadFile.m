//
//  UploadFile.m
//  iFace
//
//  Created by Yin on 15-6-19.
//  Copyright © 2015年 weicontrol. All rights reserved.
//

#import "UploadFile.h"

@interface UploadFile ()
{
    NSString *fileType;
    HTTPRequest *request;
}

@end

@implementation UploadFile

#pragma mark - --------取得数据并封装----------------
- (NSData *)packageData:(NSDictionary *)dic
{
    if (!dic) {
        return NULL;
    }
    
    NSData *data = nil;
    
    NSString *fileName = [dic objectForKey:@"fileName"];
    
    id file = [dic objectForKey:@"file"];
    
    if ([file isKindOfClass:[NSImage class]]) {
        NSImage *image = (NSImage *)file;
        NSString *ext = fileName.pathExtension;
        NSBitmapImageRep *rep = (NSBitmapImageRep *)image.representations.firstObject;
        int scale = rep.pixelsWide / image.size.width;//缩放值
        
        if (ext.length <= 0 && image) {
            ext = @"png";
            if (scale == 1) {
                fileName = [NSString stringWithFormat:@"%@.%@",fileName,ext];
            }
            else if (scale > 1) {
                NSString *scaleStr = [NSString stringWithFormat:@"@%dx",scale];
                if ([fileName hasSuffix:scaleStr]) {
                    fileName = [NSString stringWithFormat:@"%@.%@",fileName,ext];
                }else{
                    fileName = [NSString stringWithFormat:@"%@@%dx.%@",fileName,scale,ext];
                }
            }
            NSLog(@"%@",fileName);
        }
        else if (ext.length > 0 && image) {
            NSLog(@"%@",fileName);
        }else{
            NSLog(@"文件不存在");
        }
        
        data = image.TIFFRepresentation;
        fileType = @"image/jpg";
        
        //如果路径存在,直接拿取
        NSString *Path = dic[@"path"];
        if (Path) {
            data = [NSData dataWithContentsOfFile:Path];
        }
        
        if ([data length]>8000000) {
            NSLog(@"文件过大");
            return nil;
        }
    }
    else if ([file isKindOfClass:[NSData class]]) {
        data = file;
        fileType = @"stream";
        if ([fileName hasSuffix:@".txt"]) {
            //fileType = @"text/plain";
        }
    }
    
    return data;
}

- (HTTPRequest *)run:(NSString *)method body:(NSDictionary *)body delegate:(id)thedelegate
{
    request = [[HTTPRequest alloc] init];
    [request run:method body:@{@"type":@"file"} delegate:thedelegate];
    request.tag = _tag;
    request.dicTag = _dicTag;
    request.timeOut = 180;
    NSData *data = [self packageData:body];
    NSString *fileName;
    if (data) {
        fileName = [body objectForKey:@"fileName"];
    }
    //一连串上传头标签
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    request.request.HTTPMethod = @"POST";//设置为 POST
    [request addValue:contentType forHeader: @"Content-Type"];
    NSMutableData *bodyData = [NSMutableData data];
    [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[NSData dataWithData:data]];
    [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request.request setHTTPBody:bodyData];
    
    //计算数据长度
    NSInteger totalLength = bodyData.length;
    [self setValue:@(totalLength).stringValue forHeader:@"Content-length"];
    
    return request;
}

- (void)setTag:(NSString *)tag
{
    _tag = tag;
    request.tag = tag;
}

- (void)setDicTag:(NSDictionary *)dicTag
{
    _dicTag = dicTag;
    request.dicTag = dicTag;
}

- (void)setValue:(NSString *)value forHeader:(NSString *)field
{
    [request setValue:value forHeader:field];
}

- (void)addValue:(NSString *)value forHeader:(NSString *)field
{
    [request addValue:value forHeader:field];
}

- (void)addRequestHeader:(NSDictionary *)dicData
{
    [self addRequestHeader:dicData encoding:NSUTF8StringEncoding];
}

- (void)addRequestHeader:(NSDictionary *)dicData encoding:(NSStringEncoding)encoding
{
    NSAssert([dicData isKindOfClass:[NSDictionary class]], @"参数设置错误");//参数设置错误
    
    NSArray *listKeys = [dicData allKeys];
    for (NSString *key in listKeys) {
        NSString *header = key;
        NSString *value = dicData[key];
        
        //对于不是字符串类数据的处理
        if (![value isKindOfClass:[NSString class]]) {
            value = [NSString stringWithFormat:@"%@",value];
        }
        
        if (encoding) {
            value = [value stringByAddingPercentEscapesUsingEncoding:encoding];
        }
        
        [self setValue:value forHeader:header];
    }
}

- (void)start
{
    [request start];
}

- (void)cancel
{
    [request cancel];
}

@end
