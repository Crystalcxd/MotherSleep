//
//  AppDelegate.h
//  BabySleep
//
//  Created by Michael on 16/6/26.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WXApi.h"

#define WXAppId @"wxead019165d8d0b56"
#define WXAppSecret @"c90aa35d891147648fde0a4a03c632c4"

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

