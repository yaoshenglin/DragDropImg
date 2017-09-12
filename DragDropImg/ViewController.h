//
//  ViewController.h
//  DragDropImg
//
//  Created by xy on 2016/12/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DragDropImageView.h"

@interface ViewController : NSViewController

@property (weak) IBOutlet DragDropImageView *dragImgView1;//图片容器
@property (weak) IBOutlet DragDropImageView *dragImgView2;
@property (weak) IBOutlet NSTextField *imgInfo1;//图片尺寸信息
@property (weak) IBOutlet NSTextField *imgInfo2;
@property (weak) IBOutlet NSTextField *txtName1;//图片名字
@property (weak) IBOutlet NSTextField *txtName2;

@end

