//
//  MakeQrCode_ViewController.h
//  DragDropImg
//
//  Created by xy on 2018/1/3.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MakeQrCode_ViewController : NSViewController

@property (weak) IBOutlet NSTextField *lblType;
@property (weak) IBOutlet NSTextField *txtContent;
@property (weak) IBOutlet NSImageView *imgViewCode;

@end
