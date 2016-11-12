//
//  Utility.h
//  WeMedia
//
//  Created by Kyle on 14-4-1.
//  Copyright (c) 2014年 Tap Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define RGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define HexRGB(hexRGB) [UIColor colorWithRed:((float)((hexRGB & 0xFF0000) >> 16))/255.0 green:((float)((hexRGB & 0xFF00) >> 8))/255.0 blue:((float)(hexRGB & 0xFF))/255.0 alpha:1.0]
#define radians(x) ((x)*M_PI/180.0)
#define kNavBGColor HexRGB(0xff6e70)
#define kTitleColor [UIColor colorWithRed:48/255.0 green:48/255.0 blue:48/255.0 alpha:1]
#define kInfoColor [UIColor colorWithRed:158/255.0 green:158/255.0 blue:158/255.0 alpha:1]
#define kCommentColor [UIColor colorWithRed:48/255.0 green:48/255.0 blue:48/255.0 alpha:1]
#define kUserColor [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1]
#define kTimeColor [UIColor colorWithRed:158/255.0 green:158/255.0 blue:158/255.0 alpha:1]
//font


#define KEY_REGISTER @"21#D4dfge35^*0a]s[df"
#define MD5Key @"sharereader.cn!@#$%^&"
#define TABLEVIEW_BEGIN_TAG 1000
#define UNSCORE 100
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define OFFSETWIDTH 80
#define DATA_PAGE_SIZE 20
#define Scale [UIScreen mainScreen].scale
#define kWBSDKRedirectURI @"http://www.sharereader.cn"
#define kWxSDKRedirectURI @"http://weixin.qq.com/r/JXUcBHLE6S_WrTZn9yA3"
#define MANAGER_MAIL @"support@diaobao.la"
#define CANAL  @"App Store"


#define DEBUGGING
#ifdef DEBUGGING
#define SAFE_RELEASE(Objc) [Objc release];
#else
#define SAFE_RELEASE(Objc) [Objc release];Objc = nil;
#endif


typedef enum : NSUInteger {
    PlayViewTypeWindow = TABLEVIEW_BEGIN_TAG * 20,
    PlayViewTypePlayBG,
    PlayViewTypeStatusLabel,
    PlayViewTypePlayBtn,
    PlayViewTypePlayImageView,
    PlayViewTypeCircle,
    PlayViewTypePlayLabel,
    PlayViewTypeTimeLabel,
    PlayViewTypePlayBtnTwo,
    PlayViewTypeProgress,
} PlayViewType;

typedef enum : NSUInteger {
    AddViewTypeWindow = TABLEVIEW_BEGIN_TAG * 30,
    AddViewTypeAddBG,
    AddViewTypeTextField,
    AddViewTypeMusicType,
} AddViewType;

@interface Utility : NSObject

NSUInteger DeviceSystemMajorVersion();

//dateFormatter = nil use default @"YYYY-MM-dd HH:mm:ss"
+(NSString *)convertToString:(NSTimeInterval)timeInterval formatter:(NSDateFormatter *)dateFormatter;
+(NSTimeInterval)convertToTimeInterval:(NSString *)timeString formatter:(NSDateFormatter *)dateFormatter;
+(NSString *)dateStringWith:(NSInteger)time;
+ (NSString *)chatTimeStringWith:(NSInteger)time;
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;
+ (NSString *)userNameWithScore:(NSInteger)score;
/** 是否静音模式 */

+(BOOL)silenced;

+(BOOL)ifChinese;

@end
