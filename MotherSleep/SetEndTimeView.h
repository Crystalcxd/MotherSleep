//
//  SetEndTimeView.h
//  MotherSleep
//
//  Created by Michael on 2016/8/13.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetEndTimeViewDelegate;

@interface SetEndTimeView : UIView

@property (nonatomic , assign) id<SetEndTimeViewDelegate> delegate;

- (void)showView;

@end

@protocol SetEndTimeViewDelegate <NSObject>

- (void)confirmEndTimeWithDate:(NSDate *)date;

@end
