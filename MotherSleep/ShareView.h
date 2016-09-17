//
//  ShareView.h
//  BabySleep
//
//  Created by medica_mac on 16/7/6.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareViewDelegate;

@interface ShareView : UIView

@property (nonatomic , assign) id<ShareViewDelegate> delagate;

- (instancetype)initWithFrame:(CGRect)frame Name:(NSString *)name Color:(UIColor *)color selectColor:(UIColor *)selectColor;

@end

@protocol ShareViewDelegate <NSObject>

@optional

- (void)clickAction:(NSInteger)tag;

@end