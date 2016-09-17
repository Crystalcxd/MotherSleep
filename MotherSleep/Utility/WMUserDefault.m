//
//  WMUserDefault.m
//  WeMedia
//
//  Created by Kyle on 14-3-26.
//  Copyright (c) 2014年 Tap Tech. All rights reserved.
//

#import "WMUserDefault.h"

@implementation WMUserDefault

+(int)intValueForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}
+(void)setIntValue:(int)value forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



+(CGFloat)floatValueForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] floatForKey:key];
}
+(void)setFloatVaule:(CGFloat)value forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



+(BOOL)BoolValueForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
    
}
+(void)setBoolVaule:(BOOL)value forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}



+(id)objectValueForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
+(void)setObjectValue:(id)value forKey:(NSString *)key{
    if (value == nil||key == nil)
    {
        NSLog(@"setObjectValue has null vale=%@, key=%@",value,key);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+(void)setArray:(NSArray *)array forKey:(NSString *)key
{
    if (array == nil||key == nil)
    {
        NSLog(@"setArray has null vale=%@, key=%@",array,key);
        return;
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (NSArray *)arrayForKey:(NSString *)key
{
    if (key == nil) {
        NSLog(@"arrayForKey has null key=%@",key);
        return nil;
    }
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
}


@end
