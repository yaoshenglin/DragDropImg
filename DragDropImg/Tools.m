//
//  Tools.m
//  DragDropImg
//
//  Created by xy on 2017/9/12.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "Tools.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation Tools

+ (NSAlert *)alertWithMessage:(NSString *)messageText informative:(NSString *)informativeText completionHandler:(void (^)(NSModalResponse returnCode))handler
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = messageText;
    alert.informativeText = informativeText;
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"确定"];
    NSWindow *window = [NSApplication sharedApplication].windows.firstObject;
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert beginSheetModalForWindow:window completionHandler:handler];
    });
    
    return alert;
}

+ (NSString *)getPlistPath
{
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *dirPath = [NSString stringWithFormat:@"/Users/xy/Library/Containers/%@/Data/Library/Preferences",identifier];
    NSString *fileName = [NSString stringWithFormat:@"%@.plist",identifier];
    NSString *path = [dirPath stringByAppendingPathComponent:fileName];
    return path;
}

+ (NSMutableDictionary *)userDefaults
{
    NSString *path = [self getPlistPath];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo.dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    return userInfo;
}

+ (void)setObject:(id)value forKey:(NSString *)defaultName
{
    NSMutableDictionary *userInfo = [self userDefaults];
    [userInfo setObject:value forKey:defaultName];
    NSString *path = [self getPlistPath];
    [userInfo writeToFile:path atomically:YES];
}

+ (id)objectForKey:(NSString *)defaultName
{
    id value = [[Tools userDefaults] objectForKey:defaultName];
    return value;
}

#pragma mark 生成长度为length的随机字符串
+ (NSString *)getRandomByString:(NSString *)string Length:(int)length
{
    if (![string isKindOfClass:[NSString class]] || string.length <= 0) {
        //'A' ~ "Z",'a' ~ "z",'0' ~ "9"
        string = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    }
    NSString *result = @"";
    NSString *mStr = string;
    u_int32_t bounds = (u_int32_t)mStr.length;//取值范围
    for (int i = 0; i <length; i ++) {
        int ran = arc4random() % bounds;
        //ran = arc4random_uniform(bounds);
        NSString *charStr = [mStr substringWithRange:NSMakeRange(ran, 1)];
        result = [result stringByAppendingString:charStr];
    }
    return result;
}

#pragma mark 生成长度为length的随机字符串
+ (NSString *)getRandomByLength:(int)length
{
    return [self getRandomByString:nil Length:length];
}

+ (NSString *)getSystemVersionString
{
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSInteger majorVersion = processInfo.operatingSystemVersion.majorVersion;
    NSInteger minorVersion = processInfo.operatingSystemVersion.minorVersion;
    NSInteger patchVersion = processInfo.operatingSystemVersion.patchVersion;
    NSString *versionString = [NSString stringWithFormat:@"%ld.%ld.%ld",majorVersion,minorVersion,patchVersion];
    
    return versionString;
}

#pragma mark 获取系统语言和地区
+ (NSDictionary *)getLocaleLangArea
{
    NSLocale *usLocale = [NSLocale currentLocale];
    NSArray *languages = [usLocale.localeIdentifier componentsSeparatedByString:@"_"];
    if (languages.count > 1) {
        NSString *lang = MAC_OS_X_VERSION>=10 ? usLocale.languageCode : languages.firstObject;
        NSDictionary *dicValue = @{@"lang":lang,
                                   @"area":languages[1]};
        return dicValue;
    }
    
    return nil;
}

@end

@implementation NSString (NSObject)

- (NSString *)stringForFormat
{
    NSString *tempStr1 = [self stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSString *str = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:&error];
    if (error) {
        NSLog(@"format : %@",error.localizedDescription);
    }
    
    return str;
}

@end

@implementation NSDictionary (NSObject)

- (NSString *)stringForFormat
{
    NSString *str = [self.description stringForFormat];
    
    return str;
}

- (id)checkClass:(Class)aClass key:(id)key
{
    if (![self isKindOfClass:[NSDictionary class]]) {
        NSLog(@"该数据不是NSDictionary类型,%@,%@",self,key);
        return 0;
    }
    
    id result = [self objectForKey:key];
    if (!result || ![result isKindOfClass:aClass]) {
        return nil;
    }
    
    return result;
}

- (id)checkClasses:(NSArray *)listClass key:(id)key
{
    id result = [self objectForKey:key];
    if (!result) return nil;
    for (Class aClass in listClass) {
        if ([result isKindOfClass:aClass]) {
            return result;
        }
    }
    
    return nil;
}

#pragma mark 根据关键字获取对应数据
- (BOOL)existsForKey:(id)key
{
    id value = [self objectForKey:key];
    if (!value || [value isKindOfClass:[NSNull class]]) {
        return NO;
    }
    
    return YES;
}

- (int)intForKey:(id)key
{
    id value = [self checkClasses:@[NSNumber.class,NSString.class] key:key];
    int result = value ? [value intValue] : -1;
    return result;
}

- (NSInteger)integerForKey:(id)key
{
    id value = [self checkClasses:@[NSNumber.class,NSString.class] key:key];
    NSInteger result = value ? [value integerValue] : -1;
    return result;
}

- (long)longForKey:(id)key
{
    id value = [self checkClasses:@[NSNumber.class,NSString.class] key:key];
    long result = [value longValue];
    return result;
}

- (float)floatForKey:(id)key
{
    id value = [self checkClasses:@[NSNumber.class,NSString.class] key:key];
    float result = [value floatValue];
    return result;
}

- (double)doubleForKey:(id)key
{
    id value = [self checkClasses:@[NSNumber.class,NSString.class] key:key];
    double result = [value doubleValue];
    return result;
}

- (BOOL)boolForKey:(id)key
{
    id value = [self checkClasses:@[NSNumber.class,NSString.class] key:key];
    BOOL result = [value boolValue];
    return result;
}

- (NSString *)stringForKey:(id)key
{
    id value = [self checkClass:[NSString class] key:key];
    return value;
}

- (NSArray *)arrayForKey:(id)key
{
    id value = [self checkClass:[NSArray class] key:key];
    return value;
}

- (NSDictionary *)dictionaryForKey:(id)key
{
    id value = [self checkClass:[NSDictionary class] key:key];
    return value;
}

- (NSData *)dataForKey:(id)key
{
    id value = [self checkClass:[NSData class] key:key];
    return value;
}

@end

@implementation NSData (NSExt)

//判断数据对应文件类型
- (NSString *)getDtataType
{
    uint8_t c;
    [self getBytes:&c length:1];
    NSDictionary *dicType = @{@"255216":@"jpg",
                              @"7173":@"gif",
                              @"6677":@"bmp",
                              @"13780":@"png",
                              @"6787":@"swf",
                              @"7790":@"exe dll",
                              @"8297":@"rar",
                              @"8075":@"zip",
                              @"55122":@"7z",
                              @"6063":@"xml",
                              @"6033":@"html",
                              @"239187":@"aspx",
                              @"117115":@"cs",
                              @"119105":@"js",
                              @"102100":@"txt",
                              @"255254":@"sql",
                              @"254239":@"bin"};
    if (self.length<2) {
        NSLog(@"NOT FILE");
    }else{
        int char1 = 0 ,char2 =0 ; //必须这样初始化
        [self getBytes:&char1 range:NSMakeRange(0, 1)];
        [self getBytes:&char2 range:NSMakeRange(1, 1)];
        NSString *numStr = [NSString stringWithFormat:@"%i%i",char1,char2];
        NSString *type = [dicType objectForKey:numStr];
        if (type) {
            NSLog(@"下载文件类型,%@",type);
        }else{
            NSLog(@"未知文件类型,参数:%@",numStr);
        }
        
        return type;
    }
    
    return nil;
}

@end

@implementation NSObject (NSObject)

- (NSString *)customDescription
{
    if ([self isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)self stringForFormat];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [self valueForKey:propName];
        if(value == nil)
        {
            value = [NSNull null];
        }
        
        [dic setObject:value forKey:propName];
    }
    NSString *content = [dic stringForFormat];
    return content;
}

@end

#pragma mark - --------NSView------------------------
@implementation NSView (NSObject)

- (void)setOriginX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setOriginY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setOriginX:(CGFloat)x Y:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin = CGPointMake(x, y);
    self.frame = frame;
}

- (void)setMaxX:(CGFloat)maxX
{
    CGRect frame = self.frame;
    frame.origin.x = maxX - CGRectGetWidth(frame);
    self.frame = frame;
}

- (void)setMaxY:(CGFloat)maxY
{
    CGRect frame = self.frame;
    frame.origin.y = maxY - CGRectGetHeight(frame);
    self.frame = frame;
}

- (void)setSizeToW:(CGFloat)w
{
    CGRect frame = self.frame;
    frame.size.width = w;
    self.frame = frame;
}

- (void)setSizeToH:(CGFloat)h
{
    CGRect frame = self.frame;
    frame.size.height = h;
    self.frame = frame;
}

- (void)setSizeToW:(CGFloat)w height:(CGFloat)h
{
    CGRect frame = self.frame;
    frame.size = CGSizeMake(w, h);
    self.frame = frame;
}

- (void)setOriginX:(CGFloat)x width:(CGFloat)w
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    frame.size.width = w;
    self.frame = frame;
}

- (void)setOriginY:(CGFloat)y height:(CGFloat)h
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    frame.size.height = h;
    self.frame = frame;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setOrigin:(CGPoint)origin size:(CGSize)size
{
    CGRect frame = self.frame;
    frame.origin = origin;
    frame.size = size;
    self.frame = frame;
}

- (void)setOriginScale:(CGFloat)scale
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width*scale, self.frame.size.height*scale);
}

- (CGPoint)boundsCenter
{
    CGPoint center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
    return center;
}

- (void)rotation:(CGFloat)angle
{
    self.layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);//旋转angle度
    //self.transform = CGAffineTransformMakeRotation(angle);//旋转angle度
}

- (id)viewWITHTag:(NSInteger)tag
{
    NSArray *listView = self.subviews;
    NSMutableArray *list = [NSMutableArray array];
    for (NSView *v in listView) {
        if (v.tag == tag) {
            [list addObject:v];
        }
    }
    
    return list.firstObject;
}

- (id)viewWithClass:(Class)aClass
{
    NSArray *listView = self.subviews;
    NSMutableArray *list = [NSMutableArray array];
    for (NSView *v in listView) {
        if ([v isKindOfClass:[aClass class]]) {
            [list addObject:v];
        }
    }
    
    return list.firstObject;
}

- (id)viewWithClass:(Class)aClass tag:(NSInteger)tag
{
    NSArray *listView = self.subviews;
    NSMutableArray *list = [NSMutableArray array];
    for (NSView *v in listView) {
        if ([v isKindOfClass:[aClass class]] && v.tag == tag) {
            [list addObject:v];
        }
    }
    
    return list.firstObject;
}

- (NSArray *)viewsWithClass:(Class)aClass
{
    NSArray *list = @[];
    NSArray *listView = self.subviews;
    for (NSView *v in listView) {
        if ([v isKindOfClass:[aClass class]]) {
            list = [list arrayByAddingObject:v];
        }
    }
    
    return list;
}

- (id)subviewWithClass:(Class)aClass
{
    NSArray *listView = self.subviews;
    NSMutableArray *list = [NSMutableArray array];
    for (NSView *v in listView) {
        if ([v isKindOfClass:[aClass class]]) {
            [list addObject:v];
        }
        else if (v.subviews > 0) {
            NSView *subview = [v subviewWithClass:aClass];
            if (subview) {
                [list addObject:subview];
            }
        }
    }
    
    return list.firstObject;
}

- (id)subviewWithClass:(Class)aClass tag:(NSInteger)tag
{
    NSArray *listView = self.subviews;
    NSMutableArray *list = [NSMutableArray array];
    for (NSView *v in listView) {
        if ([v isKindOfClass:[aClass class]] && v.tag == tag) {
            [list addObject:v];
        }
        else if (v.subviews > 0) {
            NSView *subview = [v subviewWithClass:aClass tag:tag];
            if (subview) {
                [list addObject:subview];
            }
        }
    }
    
    return list.firstObject;
}

/*
 使用规则
 
 |: 表示父视图
 -:表示距离
 V:  :表示垂直
 H:  :表示水平
 >= :表示视图间距、宽度和高度必须大于或等于某个值
 <= :表示视图间距、宽度和高度必须小宇或等于某个值
 == :表示视图间距、宽度或者高度必须等于某个值
 @  :>=、<=、==  限制   最大为  1000
 
 1.|-[view]-|:  视图处在父视图的左右边缘内
 2.|-[view]  :   视图处在父视图的左边缘
 3.|[view]   :   视图和父视图左边对齐
 4.-[view]-  :  设置视图的宽度高度
 5.|-30.0-[view]-30.0-|:  表示离父视图 左右间距  30
 6.[view(200.0)] : 表示视图宽度为 200.0
 7.|-[view(view1)]-[view1]-| :表示视图宽度一样，并且在父视图左右边缘内
 8. V:|-[view(50.0)] : 视图高度为  50
 9: V:|-(==padding)-[imageView]->=0-[button]-(==padding)-| : 表示离父视图的距离
 为Padding,这两个视图间距必须大于或等于0并且距离底部父视图为 padding。
 10:  [wideView(>=60@700)]  :视图的宽度为至少为60 不能超过  700
 11: 如果没有声明方向默认为  水平  H:
 */
- (void)addConstraintsWithFormat:(NSString *)format views:(NSDictionary *)views
{
    NSLayoutFormatOptions options = NSLayoutFormatDirectionLeadingToTrailing;
    [self addConstraintsWithFormat:format views:views options:options];
}

- (void)addConstraintsWithFormat:(NSString *)format views:(NSDictionary *)views options:(NSLayoutFormatOptions)options
{
    if (format.length <= 0 || !views) {
        return;
    }
    
    NSDictionary *metrics = nil;
    NSArray *list = [NSLayoutConstraint constraintsWithVisualFormat:format options:options metrics:metrics views:views];
    [self addConstraints:list];
}

- (void)addConstraintsWithItem:(id)view attribute:(NSLayoutAttribute)attr
{
    if (((NSView *)view).translatesAutoresizingMaskIntoConstraints) {
        ((NSView *)view).translatesAutoresizingMaskIntoConstraints = NO;
    }
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:attr relatedBy:NSLayoutRelationEqual toItem:self attribute:attr multiplier:1.0 constant:0]];
}

- (void)addConstraintsToCenterWithItem:(id)view
{
    [self addConstraintsWithItem:view attribute:NSLayoutAttributeCenterX];
    [self addConstraintsWithItem:view attribute:NSLayoutAttributeCenterY];
}

- (void)addAnimationType:(NSString *)type subType:(NSString *)subType duration:(CFTimeInterval)duration
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:duration];
    [animation setType:type];
    [animation setSubtype:subType];
    [self.layer addAnimation:animation forKey:@"Reveal"];
}

- (void)addAnimationSetDuration:(CFTimeInterval)duration
{
    //NSImageView切换图片动画
    CATransition *animation = [CATransition animation];
    animation.duration = duration;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:animation forKey:@"Reveal"];
}

//- (void)commitAnimations
//{
//    [NSView commitAnimations];
//}

- (void)addAnimationType:(NSString *)type subType:(NSString *)subType duration:(CFTimeInterval)duration operation:(dispatch_block_t)operation completion:(dispatch_block_t)completion
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:duration];
    [animation setType:type];
    [animation setSubtype:subType];
    [self.layer addAnimation:animation forKey:@"Reveal"];
    if (operation) {
        operation();
    }
    
    if (completion) {
        dispatch_queue_t queue = dispatch_get_main_queue();
        int64_t delta = (int64_t)(duration * NSEC_PER_SEC);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), queue, ^{
            completion();
        });
    }
}

//添加虚线边框
- (void)dashLineForBorderWithRadius:(CGFloat)radius
{
    //border definitions,  lineDashPattern属性可以设定为实线还是虚线
    CGFloat cornerRadius = radius;//圆角半径
    CGFloat borderWidth = 1.0;//边框宽
    CGFloat dashPattern = 2.0;//虚线长度
    CGFloat spacePattern = 2.0;//空白区长度(如果为0则为实线)
    NSColor *lineColor = [NSColor whiteColor];//虚线颜色
    
    [self dashLineWithRadius:cornerRadius borderWidth:borderWidth dashPattern:dashPattern spacePattern:spacePattern lineColor:lineColor];
}

//添加虚线边框
- (void)dashLineWithAttributes:(NSDictionary *)attributes
{
    //border definitions,  lineDashPattern属性可以设定为实线还是虚线
    CGFloat cornerRadius = [[attributes objectForKey:@"Radius"] floatValue];//圆角半径
    CGFloat borderWidth = [[attributes objectForKey:@"Width"] floatValue];//边框宽
    CGFloat dashLen = [[attributes objectForKey:@"dashLen"] floatValue];//虚线长度
    CGFloat spaceLen = [[attributes objectForKey:@"spaceLen"] floatValue];//空白区长度(如果为0则为实线)
    NSColor *lineColor = [attributes objectForKey:@"Color"];//虚线颜色
    
    [self dashLineWithRadius:cornerRadius borderWidth:borderWidth dashPattern:dashLen spacePattern:spaceLen lineColor:lineColor];
}

- (void)dashLineWithRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth dashPattern:(CGFloat)dashPattern spacePattern:(CGFloat)spacePattern lineColor:(NSColor *)lineColor
{
    NSArray *listLayers = self.layer.sublayers;
    [listLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer) withObject:nil];
    //[listLayers perExecute:select(removeFromSuperlayer) forClass:[CAShapeLayer class]];
    
    //border definitions,  lineDashPattern属性可以设定为实线还是虚线
    NSArray *lineDashPattern = @[@(dashPattern),@(spacePattern)];//为空时是实线;
    
    //drawing
    CGRect frame = self.bounds;
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    //creating a path
    CGMutablePathRef path = CGPathCreateMutable();
    //drawing a border around a view
    CGPathMoveToPoint(path, NULL, 0, frame.size.height - radius);
    CGPathAddLineToPoint(path, NULL, 0, radius);
    CGPathAddArc(path, NULL, radius, radius, radius, M_PI, -M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width - radius, 0);
    CGPathAddArc(path, NULL, frame.size.width - radius, radius, radius, -M_PI_2, 0, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height - radius);
    CGPathAddArc(path, NULL, frame.size.width - radius, frame.size.height - radius, radius, 0, M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, radius, frame.size.height);
    CGPathAddArc(path, NULL, radius, frame.size.height - radius, radius, M_PI_2, M_PI, NO);
    
    //path is set as the _shapeLayer object's path
    shapeLayer.path = path;
    CGPathRelease(path);
    
    shapeLayer.backgroundColor = [[NSColor clearColor] CGColor];
    shapeLayer.frame = frame;
    shapeLayer.masksToBounds = NO;
    [shapeLayer setValue:@(NO) forKey:@"isCircle"];
    shapeLayer.fillColor = [[NSColor clearColor] CGColor];
    shapeLayer.strokeColor = [lineColor CGColor];
    shapeLayer.lineWidth = borderWidth;
    shapeLayer.lineDashPattern = lineDashPattern;//为空时是实线
    shapeLayer.lineCap = kCALineCapRound;
    
    //_shapeLayer is added as a sublayer of the view
    [self.layer addSublayer:shapeLayer];
    self.layer.cornerRadius = radius;
}

+ (NSImage *)imageWithSize:(CGSize)size borderColor:(NSColor *)color borderWidth:(CGFloat)borderWidth
{
//    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
//    UIGraphicsBeginImageContextWithOptions();
//    [[NSColor clearColor] set];
//    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
//    CGContextBeginPath(context);
//    CGContextSetLineWidth(context, borderWidth);
//    CGContextSetStrokeColorWithColor(context, color.CGColor);
//    CGFloat lengths[] = { 3, 1 };
//    CGContextSetLineDash(context, 0, lengths, 1);
//    CGContextMoveToPoint(context, 0.0, 0.0);
//    CGContextAddLineToPoint(context, size.width, 0.0);
//    CGContextAddLineToPoint(context, size.width, size.height);
//    CGContextAddLineToPoint(context, 0, size.height);
//    CGContextAddLineToPoint(context, 0.0, 0.0);
//    CGContextStrokePath(context);
//    NSImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    CGContextRef context = MyCreateBitmapContext(size.width*2, size.height*2);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    NSImage *image = [[NSImage alloc] initWithCGImage:imageRef size:size];
    return image;
}

CGContextRef MyCreateBitmapContext (int pixelsWide, int pixelsHigh)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    bitmapData = alloca( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        return NULL;
    }
    context = CGBitmapContextCreate (bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
        return NULL;
    }
    CGColorSpaceRelease( colorSpace );
    return context;
}

+ (float)distanceFromPoint:(CGPoint)start toPoint:(CGPoint)end
{
    float distance;
    //下面就是高中的数学，不详细解释了
    CGFloat xDist = (end.x - start.x);
    CGFloat yDist = (end.y - start.y);
    distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}

#pragma mark 获取NSView上某个点的颜色
- (NSColor *)colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    NSColor *color = [NSColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return color;
}

- (void)printAllSubViews
{
    SEL action = NSSelectorFromString(@"recursiveDescription");
    
    IMP imp = [self methodForSelector:action];
    id (*func)(id, SEL) = (void *)imp;
    id obj = func(self, action);
    NSLog(@"%@ recursive description:\n\n%@\n\n", self.className, obj);
}

@end
