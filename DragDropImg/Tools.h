//
//  Tools.h
//  DragDropImg
//
//  Created by xy on 2017/9/12.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface Tools : NSObject

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

+ (float)distanceFromPoint:(CGPoint)start toPoint:(CGPoint)end;
#pragma mark 获取UIView上某个点的颜色
- (NSColor *)colorOfPoint:(CGPoint)point;
- (void)printAllSubViews;

@end
