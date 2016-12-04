//
//  CartoonHeadView.m
//  Coupons
//
//  Created by Michael on 15/7/8.
//  Copyright (c) 2015年 Michael. All rights reserved.
//

#import "CartoonHeadView.h"

#import "Utility.h"

@implementation CartoonHeadView

- (void)dealloc
{
    self.imageView = nil;
}

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)identfier
{
    self = [super initWithFrame:frame withIdentifier:identfier];
    if (self) {
        self.titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, SCREENWIDTH, 30.43)];
        self.titleView.contentMode = UIViewContentModeScaleAspectFit;
//        [self addSubview:self.titleView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH * 0.5 - 142, 0, 284, 230)];
//        self.imageView.userInteractionEnabled = YES;
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)imageViewAnimation
{
    [UIView animateWithDuration:0.2 animations:^{
        self.imageView.frame = CGRectMake(SCREENWIDTH * 0.5 - 142 - 20, 20, 284, 230);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.imageView.frame = CGRectMake(SCREENWIDTH * 0.5 - 142, 0, 284, 230);
        } completion:^(BOOL finished) {
            
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
