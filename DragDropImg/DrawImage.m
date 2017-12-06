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
    
    NSImage *image = [NSImage imageNamed:@"msg1@2x.png"];
    NSImageView *imgView = [[NSImageView alloc] initWithFrame:dirtyRect];
    imgView.tag = 3;
    imgView.image = image;
    imgView.imageScaling = NSImageScaleProportionallyDown;
    imgView.allowsCutCopyPaste = YES;
    [self addSubview:imgView];
    imgView.layer.borderWidth = 3;
    imgView.layer.borderColor = [NSColor redColor].CGColor;
    
    imgView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDic = NSDictionaryOfVariableBindings(imgView);
    [self addConstraintsWithFormat:@"|[imgView]|" views:viewsDic];
    [self addConstraintsWithFormat:@"V:|[imgView]|" views:viewsDic];

    
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext]; // 1
    
    //字体在CoreGraphics中被废除了,移入CoreText框架中,以后再详细讨论.
    //char *aChar = "Helvetica-Bold";
    NSMutableAttributedString *mabstring = [[NSMutableAttributedString alloc] initWithString:@"This is a test of characterAttribute. 中文字符"];
    [mabstring beginEditing];
    //设置字体属性
    CTFontRef font = CTFontCreateWithName(CFSTR("CourierNewPS-ItalicMT"), 50, NULL);
    [mabstring addAttribute:(id)kCTFontAttributeName value:(__bridge id)font range:NSMakeRange(0, 4)];
    //红色
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[NSColor redColor],
                                 NSKernAttributeName: @(0.5f),
                                 NSStrokeWidthAttributeName: @(-5),
                                 NSFontAttributeName: [NSFont fontWithName:@"Georgia" size:37],
                                 NSWritingDirectionAttributeName: @[@(NSWritingDirectionLeftToRight | NSTextWritingDirectionOverride)]};
    [mabstring addAttributes:attributes range:NSMakeRange(4, mabstring.length-4)];
    
    [mabstring endEditing];
    
    //调整坐标系
    //CGContextTranslateCTM(context, 0, imageHeight);//x，y偏移值
    //CGContextScaleCTM(context, 1, -1.0);//缩放大小
    //CGContextRotateCTM(context, M_PI/4);//整体偏移角度
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)mabstring);
    CGMutablePathRef Path = CGPathCreateMutable();
    CGPathAddRect(Path, NULL ,CGRectMake(15 , 0 ,dirtyRect.size.width-10 , dirtyRect.size.height-10));
    //CGContextSetTextMatrix(context , CGAffineTransformIdentity);
    //保存现在得上下文图形状态。不管后续对context上绘制什么都不会影响真正得屏幕。
    //CGContextSaveGState(context);
    //CGContextSetTextMatrix (context, CGAffineTransformMakeTranslation(-1, -1));
    //CGContextSetTextMatrix (context, CGAffineTransformMakeRotation(M_PI)); // 纯文字偏移角度
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), Path, NULL);
    CTFrameDraw(frame,context);
    CGPathRelease(Path);
    CFRelease(framesetter);
    
//    CGImageRef clippedImageRef = CGBitmapContextCreateImage(context);
//    NSImage *clippedImage = [[NSImage alloc] initWithCGImage:clippedImageRef size:dirtyRect.size];
//    CGImageRelease(clippedImageRef);
//    NSLog(@"%@",clippedImage);
    
    //CGContextClosePath(context);
    //CGContextRelease (context);
}

//- (void)layoutSubtreeIfNeeded
//{
//    [super layoutSubtreeIfNeeded];
//}

@end

@implementation NSImage (NSObject)

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

+ (NSImage *) imageToTransparent:(NSImage *) image withColor:(NSColor *)color
{
    NSBitmapImageRep *rep = (NSBitmapImageRep *)image.representations.firstObject;
    //int scale = rep.pixelsWide / image.size.width;//缩放值
    CGSize size = image.size;
    // 分配内存
    
    CGFloat imageWidth = rep.pixelsWide;
    CGFloat imageHeight = rep.pixelsHigh;
    
    size_t perComponent = rep.bitsPerSample;
    size_t bytesPerRow = rep.bytesPerRow;
    
    uint32_t *rgbImageBuf = (uint32_t*)malloc(rep.pixelsWide * rep.pixelsHigh * 4);
    
    
    
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();//色彩空间
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, perComponent, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGRect rect = CGRectMake(0, 0, imageWidth, imageHeight);
    CGContextDrawImage(context, rect, rep.CGImage);//绘画图像区域
    
    // 遍历像素
    
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i=0; i<rep.pixelsWide; i++) {
        for (int y = 0; y<rep.pixelsHigh; y++) {
            //将像素点转成子节数组来表示---第一个表示透明度即ARGB这种表示方式。ptr[0]:透明度,ptr[1]:B,ptr[2]:G,ptr[3]:R
            
            //分别取出RGB值后。进行判断需不需要设成透明。
            
            uint8_t* ptr = (uint8_t*)pCurPtr;//1abc9b
            
            if ((ptr[1] == 0x9C || ptr[1] == 0x9B) && ptr[2] == 0xBC && (ptr[3] == 0x1A || ptr[3] == 0x1B))
            {
                //替换颜色
                ptr[1] = color.blueComponent * 0xFF;
                ptr[2] = color.greenComponent * 0xFF;
                ptr[3] = color.redComponent * 0xFF;
                
            }
            else if (ptr[0] == 0x00 || (ptr[1] > 240 && ptr[2] > 240 && ptr[3] > 240)) {
                
            }else{
                //替换颜色
                
                //NSLog(@"%02X%02X%02X",ptr[1],ptr[2],ptr[3]);
                
                ptr[1] = color.blueComponent * 0xFF;
                ptr[2] = color.greenComponent * 0xFF;
                ptr[3] = color.redComponent * 0xFF;
            }
            
            pCurPtr++;
        }
    }
    
    // 将内存转成image
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    NSImage *resultImage = [[NSImage alloc] initWithCGImage:imageRef size:size];
    
    // 释放
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return resultImage;
    
}

@end
