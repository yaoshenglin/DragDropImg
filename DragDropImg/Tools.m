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

+ (id)shareTools
{
    static Tools *tool;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        tool = [[Tools alloc] init];
    });
    
    return tool;
}

+ (NSAlert *)alertWithMessage:(NSString *)messageText informative:(NSString *)informativeText runModalHandler:(void (^)(NSModalResponse returnCode, NSString *title))handler
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = messageText;
    alert.informativeText = informativeText;
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"确定"];
    //NSWindow *window = [NSApplication sharedApplication].windows.firstObject;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSModalResponse returnCode = [alert runModal];
        NSInteger index = returnCode - NSAlertFirstButtonReturn;
        NSString *btnTitle = [alert.buttons[index] title];
        handler(returnCode,btnTitle);
    });
    
    return alert;
}

+ (NSAlert *)alertWithMessage:(NSString *)messageText informative:(NSString *)informativeText
{
    return [self alertWithMessage:messageText informative:informativeText sheetHandler:nil];
}

+ (NSAlert *)alertWithMessage:(NSString *)messageText informative:(NSString *)informativeText sheetHandler:(void (^)(NSModalResponse returnCode))handler
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = messageText;
    alert.informativeText = informativeText;
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"确定"];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSWindow *window = [Tools getLastWindow];
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

+ (NSString *)mainBundlePath
{
    NSString *dirPath = [[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent];
    return dirPath;
}

+ (NSWindow *)getLastWindow
{
    NSMutableArray *listWindows = [[NSApplication sharedApplication].windows mutableCopy];
    NSWindow *window = listWindows.lastObject;
    while ([window isKindOfClass:[NSPanel class]]) {
        [listWindows removeLastObject];
        window = listWindows.lastObject;
    }
    
    return window;
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

+ (NSStringEncoding)ConvertNSStringEncodingFromIANAChar:(NSString *)name
{
    CFStringRef textEncode = (__bridge CFStringRef)name;
    CFStringEncoding enc = CFStringConvertIANACharSetNameToEncoding(textEncode);
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (enc);
    
    return encoding;
}

+ (NSString *)ConvertIANACharFromNSStringEncoding:(NSStringEncoding)encoding
{
    CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
    CFStringRef textEncode = CFStringConvertEncodingToIANACharSetName(enc);
    NSString *textEncodingName = (__bridge NSString *)(textEncode);
    
    return textEncodingName;
}

+ (id)getControllerWithStoryboard:(NSString *)title identity:(NSString *)identifier
{
    NSStoryboard *storyBoard = nil;
    if (title==NULL) {
        //应用程序的名称和版本号等信息都保存在mainBundle的一个字典中，用下面代码可以取出来。
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        title = [infoDict objectForKey:@"NSMainStoryboardFile"];
    }
    
    storyBoard = [NSStoryboard storyboardWithName:title bundle:nil];
    if (storyBoard == NULL) {
        return NULL;
    }
    
    NSViewController *viewController = [storyBoard instantiateControllerWithIdentifier:identifier];
    return viewController;
}

#pragma mark - --------其它------------------------
+ (void)duration:(NSTimeInterval)dur block:(dispatch_block_t)block
{
    if (block) {
        dispatch_queue_t queue = dispatch_get_main_queue();
        int64_t delta = (int64_t)(dur * NSEC_PER_SEC);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), queue, block);
    }
}

/**
 异步
 
 @param block 异步执行
 */
+ (void)asyncWithBlock:(dispatch_block_t)block
{
    if (block) {
        long identifier = DISPATCH_QUEUE_PRIORITY_DEFAULT;
        dispatch_queue_t queue = dispatch_get_global_queue(identifier, 0);
        //queue = dispatch_queue_create("com.icf.serialqueue", nil);//用于异步顺序执行
        dispatch_async(queue, block);
    }
}

/**
 同步
 
 @param block 同步执行
 */
+ (void)syncWithBlock:(dispatch_block_t)block
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    if (block) dispatch_sync(queue, block);
}


/**
 异步执行完成后，同步执行
 
 @param block 异步执行
 @param nextBlock 同步执行
 */
+ (void)async:(dispatch_block_t)block complete:(dispatch_block_t)nextBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        if (block) block();
        dispatch_queue_t queue = dispatch_get_main_queue();
        if (nextBlock) dispatch_async(queue, nextBlock);
    });
}

#pragma mark 生成图片
+ (NSImage *)generateWithQRCodeData:(NSString *)imgStr title:(NSString *)title frame:(CGRect)frame
{
    // 1、创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 恢复滤镜的默认属性
    [filter setDefaults];
    
    // 2、设置数据
    NSString *info = imgStr;
    // 将字符串转换成
    NSData *infoData = [info dataUsingEncoding:NSUTF8StringEncoding];
    
    // 通过KVC设置滤镜inputMessage数据
    [filter setValue:infoData forKeyPath:@"inputMessage"];
    
    // 3、获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    
    CGRect extent = CGRectIntegral(outputImage.extent);
    CGSize size = frame.size;
    CGFloat scale = size.width/CGRectGetWidth(extent);//备用，可以缩放图片
    
    // 1.创建bitmap;
    size_t width = size.width * scale;
    size_t height = size.height * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    
    CGFloat s = 20;
    CIContext *context = [CIContext context];//上下文
    CGImageRef bitmapImage = [context createCGImage:outputImage fromRect:extent];
    //bitmapImage = outputImage.CGImage;
    [context clearCaches];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, CGRectMake(s, s, size.width-s*2, size.height-s*2), bitmapImage);
    CGContextSaveGState(bitmapRef);
    
    //字体在CoreGraphics中被废除了,移入CoreText框架中,以后再详细讨论.
    //char *aChar = "Helvetica-Bold";
    //段落格式
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;//水平居中
    //设置字体属性
    NSFont *font = [NSFont fontWithName:@"Helvetica-Bold" size:13];
    NSDictionary *attributes = @{NSFontAttributeName:font,
                                 NSForegroundColorAttributeName:[NSColor redColor],
                                 NSParagraphStyleAttributeName:textStyle};
    title = title ?: @"";
    NSMutableAttributedString *mabstring = [[NSMutableAttributedString alloc] initWithString:title attributes:attributes];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)mabstring);
    CGMutablePathRef Path = CGPathCreateMutable();
    CGPathAddRect(Path, NULL ,CGRectMake(0 , frame.size.height-s ,frame.size.width , s));
    //CGContextSetTextMatrix(bitmapRef , CGAffineTransformIdentity);
    //保存现在得上下文图形状态。不管后续对context上绘制什么都不会影响真正得屏幕。
    //CGContextSaveGState(bitmapRef);
    //CGContextSetTextMatrix (bitmapRef, CGAffineTransformMakeTranslation(-1, -1));
    //CGContextSetTextMatrix (bitmapRef, CGAffineTransformMakeRotation(M_PI)); // 纯文字偏移角度
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), Path, NULL);
    CTFrameDraw(frameRef,bitmapRef);
    CGPathRelease(Path);
    CFRelease(framesetter);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [[NSImage alloc] initWithCGImage:scaledImage size:frame.size];
}

@end

#pragma mark - --------NSExtends------------------------
#pragma mark --------NSString------------------------
@implementation NSString (NSExtends)

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

- (NSString *)replaceString:(NSString *)target withString:(NSString *)replacement
{
    NSString *result = [self stringByReplacingOccurrencesOfString:target withString:replacement];
    return result;
}

@end

#pragma mark - --------NSDictionary------------------------
@implementation NSDictionary (NSExtends)

- (NSString *)stringForFormat
{
    NSString *str = [NSString stringWithFormat:@"%@",self];
    str = [str stringForFormat];
    
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

#pragma mark - --------NSData------------------------
@implementation NSData (NSExt)

- (id)unarchiveData
{
    id obj = [NSKeyedUnarchiver unarchiveObjectWithData:self];
    return obj;
}

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
                              @"6690":@"dmg",
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

#pragma mark - --------NSObject------------------------
@implementation NSObject (NSExtends)

- (NSData *)archivedData
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return data;
}

- (NSString *)customDescription
{
    if ([self isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)self stringForFormat];
    }
    else if ([self isKindOfClass:[NSString class]]) {
        return [(NSString *)self stringForFormat];
    }
    else if ([self isKindOfClass:[NSArray class]]) {
        NSString *value = [NSString stringWithFormat:@"%@",self];
        value = [value stringForFormat];
        return value;
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

#pragma mark - 通过对象获取全部属性
- (NSArray *)getObjectPropertyList
{
    //纯property
    NSArray *list = nil;
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
    list = propsCount>0 ? @[] : nil;
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        
        const char *name = property_getName(prop);
        NSString *propName = [NSString stringWithUTF8String:name];
        propName = [propName replaceString:@"_" withString:@""];
        list = [list arrayByAddingObject:propName];
    }
    
    free(props);
    
    return list;
}

- (NSArray *)getObjectIvarList
{
    //包括property
    NSArray *list = nil;
    unsigned int propsCount;
    Ivar *ivar = class_copyIvarList([self class], &propsCount);
    list = propsCount>0 ? @[] : nil;
    for(int i = 0;i < propsCount; i++) {
        Ivar var = ivar[i];
        const char *name = ivar_getName(var);
        NSString *propName = [NSString stringWithUTF8String:name];
        propName = [propName replaceString:@"_" withString:@""];
        list = [list arrayByAddingObject:propName];
    }
    
    free(ivar);
    
    return list;
}

@end

#pragma mark - --------NSView------------------------
@implementation NSView (NSExtends)

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

- (NSArray *)allSubviewWithClass:(Class)aClass array:(NSMutableArray *)list
{
    NSArray *listView = self.subviews;
    list = list ?: [NSMutableArray array];
    for (NSView *v in listView) {
        if (v.subviews > 0) {
            [v allSubviewWithClass:aClass array:list];
        }
        
        if ([v isKindOfClass:[aClass class]]) {
            [list addObject:v];
        }
        
        //NSLog(@"%@",v);
    }
    
    return list;
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

- (void)logAllSubViews
{
    NSArray *list = self.subviews;
    for (NSView *view in list) {
        if ([view respondsToSelector:@selector(subviews)] && view.subviews) {
            [view logAllSubViews];
        }else{
            NSLog(@"%@",view);
        }
    }
    
    if (!list.count) {
        NSLog(@"%@",self);
    }
}

@end
