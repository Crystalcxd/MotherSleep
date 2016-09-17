//
//  TouchAnimationView.m
//  demo
//
//  Created by medica_mac on 16/7/11.
//  Copyright © 2016年 com.medica. All rights reserved.
//

#import "TouchAnimationView.h"

@implementation TouchAnimationView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    self.backgroundColor=[UIColor clearColor];
    
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
//    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect))];
//    [UIColor.redColor setStroke];
//    ovalPath.lineWidth = 0.5;
//    [ovalPath stroke];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /*写文字*/
    CGContextSetRGBFillColor (context,  1, 0, 0, 1.0);//设置填充颜色
    
    /*画圆*/
    //边框圆
    CGContextSetRGBStrokeColor(context,220/255.0,120/255.0,255/255.0,1.0);//画笔线的颜色
    CGContextSetLineWidth(context, 0.6);//线的宽度
    //void CGContextAddArc(CGContextRef c,CGFloat x, CGFloat y,CGFloat radius,CGFloat startAngle,CGFloat endAngle, int clockwise)1弧度＝180°/π （≈57.3°） 度＝弧度×180°/π 360°＝360×π/180 ＝2π 弧度
    // x,y为圆点坐标，radius半径，startAngle为开始的弧度，endAngle为 结束的弧度，clockwise 0为顺时针，1为逆时针。
    CGContextAddArc(context, CGRectGetWidth(rect) * 0.5, CGRectGetWidth(rect) * 0.5 , CGRectGetWidth(rect) * 0.5 - 1.5, 0, 2*M_PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathStroke); //绘制路径
}

- (void)disappearAnimation
{
    __weak typeof (self) weakSelf = self;

    [UIView animateWithDuration:0.5 animations:^{
        [weakSelf setTransform:CGAffineTransformMakeScale(64.0/44, 64.0/44)];
        [weakSelf setAlpha:0.0];
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
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
