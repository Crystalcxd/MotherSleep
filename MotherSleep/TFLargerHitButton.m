//
//  TFLargerHitButton.m
//  Tofu
//
//  Created by 尹晓宇 on 15/8/27.
//  Copyright (c) 2015年 Tap Tech Inc. All rights reserved.
//

#import "TFLargerHitButton.h"

@implementation TFLargerHitButton

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    
    return self;
}

// 重写此方法用于扩充可点击区域。
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGFloat delta = 42 - CGRectGetWidth(self.bounds);
    
    if (delta > 0 && self.hitMargin == 0) {
        self.hitMargin = delta;
    }
    
    CGRect largerFrame = CGRectMake(0 - self.hitMargin, 0 - self.hitMargin, self.frame.size.width + self.hitMargin*2, self.frame.size.height + self.hitMargin*2);
    
    return (CGRectContainsPoint(largerFrame, point) == 1) ? self : nil;
}

@end
