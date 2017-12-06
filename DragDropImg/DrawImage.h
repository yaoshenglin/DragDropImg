//
//  DrawImage.h
//  DragDropImg
//
//  Created by xy on 2017/11/27.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface DrawImage : NSView

@end

@interface NSImage (NSObject)

//将NSImage *转换为CGImageRef
+ (CGImageRef)nsImageToCGImageRef:(NSImage *)image;
//将NSImage转换为CIImage
+ (CIImage *)nsImageToCIImage:(NSImage *)image;

+ (NSImage*) imageToTransparent:(NSImage *) image withColor:(NSColor *)color;

@end
