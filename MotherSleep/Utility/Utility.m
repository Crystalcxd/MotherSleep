//
//  Utility.m
//  WeMedia
//
//  Created by Kyle on 14-4-1.
//  Copyright (c) 2014年 Tap Tech. All rights reserved.
//

#import "Utility.h"

#import <AudioToolbox/AudioToolbox.h>


@implementation Utility


NSUInteger DeviceSystemMajorVersion(){
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
	});
    
	return _deviceSystemMajorVersion;
}



+(NSString *)convertToString:(NSTimeInterval)timeInterval formatter:(NSDateFormatter *)dateFormatter;
{
    NSDateFormatter *defaultMatter = nil;
    if (dateFormatter == nil) {
        defaultMatter = [[NSDateFormatter alloc] init];
        [defaultMatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString *dateStrng = nil;
    if (dateFormatter != nil) {
        dateStrng= [dateFormatter stringFromDate:date];
    }else{
        dateStrng= [defaultMatter stringFromDate:date];

    }
    return dateStrng;
}

+(NSTimeInterval)convertToTimeInterval:(NSString *)timeString formatter:(NSDateFormatter *)dateFormatter
{
    NSDateFormatter *defaultMatter = nil;
    if (dateFormatter == nil) {
        defaultMatter = [[NSDateFormatter alloc] init];
        [defaultMatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
    NSDate *date  = nil;
    
    if (dateFormatter != nil) {
        date = [dateFormatter dateFromString:timeString];
    }else{
        date = [defaultMatter dateFromString:timeString];
    }
    return [date timeIntervalSince1970];
}
+(NSString *)dateStringWith:(NSInteger)time
{
    NSInteger length = 60*60*24*30*12;//一年
    
    NSString *dateString = nil;
    
    NSInteger currenttime = [[NSDate date] timeIntervalSince1970];
    NSInteger distance = currenttime - time;
    
    if (distance/(length) >= 1) {
        dateString = [NSString stringWithFormat:@"%ld年前",distance/length];
        return dateString;
    }
    length = length/12;
    if (distance/(length) >= 1) {
        dateString = [NSString stringWithFormat:@"%ld个月前",distance/length];
        return dateString;
    }
    length = length/30;
    if (distance/length >= 1) {
        if (distance/(length) == 1) {
            dateString = @"昨天";
            return dateString;
        }else{
            dateString = [NSString stringWithFormat:@"%ld天前",distance/length];
            return dateString;
        }
    }
    length = length/24;
    if (distance/(length) >= 1) {
        dateString = [NSString stringWithFormat:@"%ld小时前",distance/length];
        return dateString;
    }
    length = length/60;
    if (distance/(length) >= 1) {
        dateString = [NSString stringWithFormat:@"%ld分钟前",distance/length];
        return dateString;
    }else
        return @"刚刚";
}

+ (NSString *)chatTimeStringWith:(NSInteger)time
{
    NSDateFormatter *defaultMatter = nil;
    
    defaultMatter = [[NSDateFormatter alloc] init];
    [defaultMatter setDateFormat:@"YYYY-MM-dd"];
    
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDate *curDate = [NSDate date];
    
    NSString *timeString = [defaultMatter stringFromDate:timeDate];
    NSString *curString = [defaultMatter stringFromDate:curDate];
    if ([timeString isEqual:curString]) {
        [defaultMatter setDateFormat:@"HH:mm"];
        NSString *tempString = [defaultMatter stringFromDate:timeDate];
        return [NSString stringWithFormat:@"今天 %@",tempString];
    }
    
    [defaultMatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *tempString = [defaultMatter stringFromDate:timeDate];
    return tempString;
}

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

+(NSString *)userNameWithScore:(NSInteger)score
{
    NSString *str = @"";
    
    if (score < 30) {
        str = @"听写新手";
    }else if (score < 60) {
        str = @"听写熟手";
    }else if (score < 100) {
        str = @"听写一级高手";
    }else if (score < 200) {
        str = @"听写二级高手";
    }else if (score < 300) {
        str = @"听写三级高手";
    }else if (score < 400) {
        str = @"听写四级高手";
    }else if (score < 500) {
        str = @"听写大师";
    }else if (score < 800) {
        str = @"听写高级大师";
    }else{
        str = @"听写高级大师";
    }
    
    return str;
}

+(BOOL)silenced
{
    CFStringRef route;
    UInt32 routeSize = sizeof(CFStringRef);
    
    OSStatus status = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &routeSize, &route);
    if (status == kAudioSessionNoError)
    {
        if (route == NULL || !CFStringGetLength(route))
            return TRUE;
    }
    
    return FALSE;
}

+(BOOL)ifChinese
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    return [currentLanguage containsString:@"zh"];
}

@end
