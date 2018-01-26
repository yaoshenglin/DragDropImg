//
//  Person.m
//  DragDropImg
//
//  Created by xy on 2018/1/23.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "Person.h"

@interface Person ()
{
    NSString *addr;
}

@end

@implementation Person

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self testKVO];
    }
    
    return self;
}

/*1.注册，指定被观察者的属性*/
- (void)testKVO
{
    [self addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"addr" options:NSKeyValueObservingOptionNew context:nil];
}

/*2.实现回调方法*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"name"]) {
        NSLog(@"Name is changed! new = %@",[change valueForKey:NSKeyValueChangeNewKey]);
    }
    else if ([keyPath isEqualToString:@"age"]) {
        NSLog(@"Age is changed! new = %@",[change valueForKey:NSKeyValueChangeNewKey]);
    }
    else if ([keyPath isEqualToString:@"addr"]) {
        NSLog(@"Addr is changed! new = %@",[change valueForKey:NSKeyValueChangeNewKey]);
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/*3.移除通知*/
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"name" context:nil];
    [self removeObserver:self forKeyPath:@"age" context:nil];
    [self removeObserver:self forKeyPath:@"addr" context:nil];
}

@end
