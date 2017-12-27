//
//  DrawImage_ViewController.m
//  DragDropImg
//
//  Created by xy on 2017/12/27.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "DrawImage_ViewController.h"
#import "DrawImage.h"
#import "Tools.h"

@interface DrawImage_ViewController ()
{
    DrawImage *drawView;
}

@end

@implementation DrawImage_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupSubViews
{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSImageView *imgView = [[NSImageView alloc] initWithFrame:self.view.bounds];
    imgView.tag = 3;
    imgView.imageScaling = NSImageScaleProportionallyDown;
    imgView.allowsCutCopyPaste = YES;
    [self.view addSubview:imgView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:@"/Volumes/Apple/OS工程/DragDropImg/DragDropImg/Resource/配置iFace@2x.png"];
        NSColor *color = [NSColor colorWithRed:0x00/255.0 green:0xA0/255.0 blue:0xE9/255.0 alpha:1];
        image = [NSImage imageToTransparent:image withColor:color];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            imgView.image = image;
        });
    });
    
    
    drawView = [[DrawImage alloc] initWithFrame:self.view.bounds];
    drawView.layerContentsPlacement = NSViewLayerContentsPlacementCenter;
    [self.view addSubview:drawView];
    
    drawView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDic = NSDictionaryOfVariableBindings(drawView);
    [self.view addConstraintsWithFormat:@"|[drawView]|" views:viewsDic];
    [self.view addConstraintsWithFormat:@"V:|[drawView]|" views:viewsDic];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
