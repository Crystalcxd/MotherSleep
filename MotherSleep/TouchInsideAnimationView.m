//
//  TouchInsideAnimationView.m
//  BabySleep
//
//  Created by Michael on 2016/7/24.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "TouchInsideAnimationView.h"

@implementation TouchInsideAnimationView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = CGRectGetWidth(frame) * 0.5;
        
        self.backgroundColor = [UIColor colorWithRed:220.0/255 green:120.0/255  blue:255/255 alpha:0.5];
    }
    
    return self;
}

- (void)disappearAnimation
{
    __weak typeof (self) weakSelf = self;

    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [UIColor colorWithRed:220.0/255 green:120.0/255  blue:255/255 alpha:1.0];
        [weakSelf setTransform:CGAffineTransformScale(weakSelf.transform, 12.0/8, 12.0/8)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.backgroundColor = [UIColor colorWithRed:220.0/255 green:120.0/255  blue:255/255 alpha:0.0];
            [weakSelf setTransform:CGAffineTransformScale(weakSelf.transform, 6.0/12, 6.0/12)];
        } completion:^(BOOL finished) {
            [weakSelf removeFromSuperview];
        }];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
