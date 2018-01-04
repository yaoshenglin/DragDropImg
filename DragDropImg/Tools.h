//
//  Tools.h
//  DragDropImg
//
//  Created by xy on 2017/9/12.
//  Copyright © 2017年 xy. All rights reserved.
//

#define MAC_OS_X_VERSION [[Tools getSystemVersionString] floatValue]
#define MAC_OS_X_VERSIONString [NSProcessInfo processInfo].operatingSystemVersionString

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface Tools : NSObject

//@property (nonatomic, weak) NSMutableArray *list;

+ (id)shareTools;

+ (NSAlert *)alertWithMessage:(NSString *)messageText informative:(NSString *)informativeText runModalHandler:(void (^)(NSModalResponse returnCode, NSString *title))handler;
+ (NSAlert *)alertWithMessage:(NSString *)messageText informative:(NSString *)informativeText sheetHandler:(void (^)(NSModalResponse returnCode))handler;
+ (NSString *)mainBundlePath;
+ (NSWindow *)getLastWindow;
+ (NSMutableDictionary *)userDefaults;
+ (void)setObject:(id)value forKey:(NSString *)defaultName;
+ (id)objectForKey:(NSString *)defaultName;

#pragma mark 生成长度为length的随机字符串
+ (NSString *)getRandomByString:(NSString *)string Length:(int)length;
#pragma mark 生成长度为length的随机字符串
+ (NSString *)getRandomByLength:(int)length;

+ (NSString *)getSystemVersionString;
#pragma mark 获取系统语言和地区
+ (NSDictionary *)getLocaleLangArea;

+ (NSStringEncoding)ConvertNSStringEncodingFromIANAChar:(NSString *)name;
+ (NSString *)ConvertIANACharFromNSStringEncoding:(NSStringEncoding)encoding;

+ (id)getControllerWithStoryboard:(NSString *)title identity:(NSString *)identifier;

#pragma mark - --------其它------------------------
+ (void)duration:(NSTimeInterval)dur block:(dispatch_block_t)block;
+ (void)asyncWithBlock:(dispatch_block_t)block;
+ (void)syncWithBlock:(dispatch_block_t)block;
+ (void)async:(dispatch_block_t)block complete:(dispatch_block_t)nextBlock;

#pragma mark 生成图片
/**
 *  生成一张普通的二维码
 *
 *  @param imgStr    传入你要生成二维码的数据
 */
+ (NSImage *)generateWithQRCodeData:(NSString *)imgStr frame:(CGRect)frame;

@end

@interface NSString (NSObject)

- (NSString *)stringForFormat;

@end

@interface NSDictionary (NSObject)

#pragma mark 根据关键字获取对应数据
- (BOOL)existsForKey:(id)key;
- (int)intForKey:(id)key;
- (NSInteger)integerForKey:(id)key;
- (long)longForKey:(id)key;
- (float)floatForKey:(id)key;
- (double)doubleForKey:(id)key;
- (BOOL)boolForKey:(id)key;
- (NSString *)stringForKey:(id)key;
- (NSArray *)arrayForKey:(id)key;
- (NSDictionary *)dictionaryForKey:(id)key;
- (NSData *)dataForKey:(id)key;

@end

@interface NSData (NSExt)

//判断数据对应文件类型
- (NSString *)getDtataType;

@end

@interface NSObject (NSObject)

- (NSString *)customDescription;

@end

#pragma mark - UIView
@interface NSView (NSObject)

- (void)setOriginX:(CGFloat)x;
- (void)setOriginY:(CGFloat)y;
- (void)setOriginX:(CGFloat)x Y:(CGFloat)y;
- (void)setMaxX:(CGFloat)maxX;
- (void)setMaxY:(CGFloat)maxY;
- (void)setSizeToW:(CGFloat)w;
- (void)setSizeToH:(CGFloat)h;
- (void)setSizeToW:(CGFloat)w height:(CGFloat)h;
- (void)setOriginX:(CGFloat)x width:(CGFloat)w;
- (void)setOriginY:(CGFloat)y height:(CGFloat)h;

- (void)setOrigin:(CGPoint)origin;
- (void)setSize:(CGSize)size;
- (void)setOrigin:(CGPoint)origin size:(CGSize)size;


- (void)setOriginScale:(CGFloat)scale;

- (CGPoint)boundsCenter;

- (void)rotation:(CGFloat)angle;//旋转angle度

- (id)viewWITHTag:(NSInteger)tag;
- (id)viewWithClass:(Class)aClass;
- (id)viewWithClass:(Class)aClass tag:(NSInteger)tag;
- (NSArray *)viewsWithClass:(Class)aClass;//该类的合集
- (id)subviewWithClass:(Class)aClass;
- (id)subviewWithClass:(Class)aClass tag:(NSInteger)tag;//遍历子视图

//添加视图约束
- (void)addConstraintsWithFormat:(NSString *)format views:(NSDictionary *)views;
- (void)addConstraintsWithFormat:(NSString *)format views:(NSDictionary *)views options:(NSLayoutFormatOptions)options;
- (void)addConstraintsWithItem:(id)view attribute:(NSLayoutAttribute)attr;
- (void)addConstraintsToCenterWithItem:(id)view;

//视图切换动画
- (void)addAnimationType:(NSString *)type subType:(NSString *)subType duration:(CFTimeInterval)duration;
- (void)addAnimationSetDuration:(CFTimeInterval)duration;
//- (void)commitAnimations;
- (void)addAnimationType:(NSString *)type subType:(NSString *)subType duration:(CFTimeInterval)duration operation:(dispatch_block_t)operation completion:(dispatch_block_t)completion;


//添加虚线边框
- (void)dashLineForBorderWithRadius:(CGFloat)radius;
- (void)dashLineWithAttributes:(NSDictionary *)attributes;
- (void)dashLineWithRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth dashPattern:(CGFloat)dashPattern spacePattern:(CGFloat)spacePattern lineColor:(NSColor *)lineColor;

+ (NSImage *)imageWithSize:(CGSize)size borderColor:(NSColor *)color borderWidth:(CGFloat)borderWidth;

CGContextRef MyCreateBitmapContext (int pixelsWide, int pixelsHigh);

+ (float)distanceFromPoint:(CGPoint)start toPoint:(CGPoint)end;
#pragma mark 获取UIView上某个点的颜色
- (NSColor *)colorOfPoint:(CGPoint)point;
- (void)printAllSubViews;

@end
