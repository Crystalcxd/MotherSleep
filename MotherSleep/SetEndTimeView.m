//
//  SetEndTimeView.m
//  MotherSleep
//
//  Created by Michael on 2016/8/13.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "SetEndTimeView.h"

#import "Utility.h"

@interface SetEndTimeView ()

@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIView *boardView;

@property (nonatomic , strong) NSDate *currentDate;

@end

@implementation SetEndTimeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bgView = [[UIView alloc] initWithFrame:frame];
        self.bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        self.bgView.alpha = 0.0;
        [self addSubview:self.bgView];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fadeView)];
        [self addGestureRecognizer:recognizer];
        
        self.boardView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 180)];
        self.boardView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.boardView];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(0, 0, 60, 40);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(fadeView) forControlEvents:UIControlEventTouchUpInside];
        [self.boardView addSubview:cancelBtn];
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmBtn.frame = CGRectMake(SCREENWIDTH - 60, 0, 60, 40);
        [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(confirmEndTime) forControlEvents:UIControlEventTouchUpInside];
        [self.boardView addSubview:confirmBtn];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"请设置音乐停止时间";
        [self.boardView addSubview:titleLabel];
        
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, SCREENWIDTH, 140)];
        picker.datePickerMode = UIDatePickerModeDateAndTime;
        picker.minimumDate = [NSDate date];
        self.currentDate = [NSDate date];
        picker.date = [NSDate date];
        [picker addTarget:self action:@selector(oneDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        picker.timeZone = [NSTimeZone timeZoneWithName:@"GTM+8"]; // 设置时区，中国在东八区
        [self.boardView addSubview:picker];
    }
    
    return self;
}

- (void)showView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.boardView.frame;
        frame.origin.y = SCREENHEIGHT - 180;
        self.boardView.frame = frame;
        
        self.bgView.alpha = 0.3;
    }];
}

- (void)fadeView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.boardView.frame;
        frame.origin.y = SCREENHEIGHT;
        self.boardView.frame = frame;
        
        self.bgView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)confirmEndTime
{
    if ([self.currentDate timeIntervalSince1970] <= [[NSDate date] timeIntervalSince1970]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"设置失败" message:@"请选择晚于当前时刻的时间" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(confirmEndTimeWithDate:)]) {
        [self.delegate confirmEndTimeWithDate:self.currentDate];
    }
    
    [self fadeView];
}

#pragma mark - 实现oneDatePicker的监听方法
- (void)oneDatePickerValueChanged:(UIDatePicker *) sender {
    
    self.currentDate = [sender date];
    
    NSDate *select = [sender date]; // 获取被选中的时间
    NSDateFormatter *selectDateFormatter = [[NSDateFormatter alloc] init];
    selectDateFormatter.dateFormat = @"yy:MM:dd HH:mm:ss"; // 设置时间和日期的格式
    NSString *dateAndTime = [selectDateFormatter stringFromDate:select]; // 把date类型转为设置好格式的string类型
    
    // 通过UIAlertView显示出来
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"时间提示" message:dateAndTime delegate:select cancelButtonTitle:@"Cancle" otherButtonTitles:nil, nil];
//    [alertView show];
    
    // 在控制台打印消息
    NSLog(@"%@", [sender date]);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
