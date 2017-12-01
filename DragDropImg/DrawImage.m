//
//  DrawImage.m
//  DragDropImg
//
//  Created by xy on 2017/11/27.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <CoreImage/CIFilter.h>
#import "DrawImage.h"
#import "Tools.h"

@implementation DrawImage

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort]; // 1
    // ********** Your drawing code here **********                             // 2
    CGContextSetRGBFillColor (myContext, 1, 0, 0, 1);                           // 3
    CGContextFillRect (myContext, CGRectMake (0, 0, 200, 100 ));                // 4
    CGContextSetRGBFillColor (myContext, 0, 0, 1, .5);                          // 5
    CGContextFillRect (myContext, CGRectMake (0, 0, 100, 200));                 // 6
    
    NSImage *image = [NSImage imageNamed:@"msg1@2x.png"];
    CGImageRef imageRef = [self.class nsImageToCGImageRef:image];
    CGContextDrawImage(myContext, NSMakeRect(0, 0, 50, 50), imageRef);
    
    CGContextClosePath(myContext);
    CGContextRelease (myContext);
}

@end

@implementation NSImage (NSObject)

- (NSImage *)replaceColorWith:(NSColor *)color
{
    CGSize size = CGSizeMake(self.size.width, self.size.height);
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image lockFocus];
    
    CGImageRef imageRef = [NSImage nsImageToCGImageRef:self]; //
    CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(myContext, *(CGRect*)&bounds, imageRef);
    
    CGContextBeginPath(myContext);
    CGRect mediaBox = CGRectMake (0, 0, size.width, size.height);
    CFStringRef myKeys[1];
    CFTypeRef myValues[1];
    myKeys[0] = kCGPDFContextMediaBox;
    myValues[0] = (CFTypeRef) CFDataCreate(NULL,(const UInt8 *)&mediaBox, sizeof (CGRect));
    CFDictionaryRef pageDictionary = CFDictionaryCreate(NULL, (const void **) myKeys,
                                                        (const void **) myValues, 1,
                                                        &kCFTypeDictionaryKeyCallBacks,
                                                        & kCFTypeDictionaryValueCallBacks);
    CGPDFContextBeginPage(myContext, pageDictionary);
    //CGContextSetRGBFillColor (myContext, 1, 0, 0, 1);
    
    CGFloat degree = 1.0;
    for (CGFloat x = 0.5; x < size.width; ) {
        for (CGFloat y = 0.5; y < size.height; ) {
            NSColor *theColor = [NSImage colorBy:self atPixel:CGPointMake(x, y)];
            const CGFloat *cs = CGColorGetComponents(theColor.CGColor);
            size_t index = CGColorGetNumberOfComponents(theColor.CGColor);
            BOOL isNeedFill = YES;
            if (index==2) {
                NSLog(@"%f,%f",cs[0],cs[1]);
            }
            if (index==3) {
                NSLog(@"%f,%f",cs[0],cs[1]);
            }
            if (index==4) {
                //NSLog(@"%f,%f,%f,%f",cs[0],cs[1],cs[2],cs[3]);
                if (cs[3] == 0 || (cs[0] == cs[1] && cs[1] == cs[2])) {
                    isNeedFill = NO;
                }
                else if (cs[0] > 0.9 && cs[1] > 0.9 && cs[2] > 0.9){
                    isNeedFill = NO;
                }else{
                    //NSLog(@"%f,%f,%f,%f",cs[0],cs[1],cs[2],cs[3]);
                }
            }
            if (isNeedFill) {
                CGRect rect = CGRectMake(x-degree, y-degree, x, y);
                [color setFill];
                NSRectFill(rect);
            }
            
            y = y + degree;
        }
        
        x = x + degree;
        [NSThread sleepForTimeInterval:0.1];
    }
    
//    color = [NSColor colorWithRed:1 green:1 blue:1 alpha:0];
//    [color setFill];
//    NSRectFill(CGRectMake(0, 0, size.width, size.height));
    
//    [color setFill];
//    NSRectFill(bounds);
//    CGContextSetBlendMode(myContext, kCGBlendModeLighten);
//    CGContextSetBlendMode(myContext, kCGBlendModeDestinationIn);
//    CGContextSaveGState(myContext);
    
    CGContextSaveGState(myContext);
    [image unlockFocus];
    
    CGContextClosePath(myContext);
    CGPDFContextEndPage(myContext);
    
    // ********** Your drawing code here **********
    CGImageRelease(imageRef);
//    CGContextRelease (myContext);
    
    return image;
}

//将CGImageRef转换为NSImage *
+ (NSImage *)imageFromCGImageRef:(CGImageRef)imageRef
{
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    
    // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(imageRef);
    imageRect.size.width = CGImageGetWidth(imageRef);
    
    // Create a new image to receive the Quartz image data.
    NSImage *image = [[NSImage alloc] initWithSize:imageRect.size];
    [image lockFocus];
    
    // Get the Quartz context and draw.
    CGContextRef imageContext = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, imageRef);
    CGContextSetBlendMode(imageContext, kCGBlendModeLighten);
    [image unlockFocus];
    CGContextRelease (imageContext);
    
    return image;
}

//将NSImage *转换为CGImageRef
+ (CGImageRef)nsImageToCGImageRef:(NSImage *)image
{
    NSData *imageData = [image TIFFRepresentation];
    CGImageRef imageRef = NULL;
    if (imageData)
    {
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData,  NULL);
        imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    }
    return imageRef;
}

//将NSImage转换为CIImage
+ (CIImage *)nsImageToCIImage:(NSImage *)image
{
    // convert NSImage to bitmap
    NSImage *myImage  = image;
    NSData  *tiffData = [myImage TIFFRepresentation];
    NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:tiffData];
    
    // create CIImage from bitmap
    CIImage *ciImage = [[CIImage alloc] initWithBitmapImageRep:bitmap];
    
    // create affine transform to flip CIImage
    NSAffineTransform *affineTransform = [NSAffineTransform transform];
    [affineTransform translateXBy:0 yBy:128];
    [affineTransform scaleXBy:1 yBy:-1];
    
    // create CIFilter with embedded affine transform
    CIFilter *transform = [CIFilter filterWithName:@"CIAffineTransform"];
    [transform setValue:ciImage forKey:@"inputImage"];
    [transform setValue:affineTransform forKey:@"inputTransform"];
    
    // get the new CIImage, flipped and ready to serve
    CIImage *result = [transform valueForKey:@"outputImage"];
    
    // draw to view
    [result drawAtPoint: NSMakePoint ( 0,0 )
               fromRect: NSMakeRect  ( 0,0,128,128 )
              operation: NSCompositeSourceOver
               fraction: 1.0];
    // cleanup
    return result;
}

+ (NSColor *)colorBy:(NSImage *)image atPixel:(CGPoint)point
{
    // Cancel if point is outside image coordinates
    CGSize size = image.size;
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, size.width, size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = [NSImage nsImageToCGImageRef:image];
    NSUInteger width = size.width;
    NSUInteger height = size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    CGImageRelease(cgImage);
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [NSColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
