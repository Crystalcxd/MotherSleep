//
//  WMUserDefault.h
//  WeMedia
//
//  Created by Kyle on 14-3-26.
//  Copyright (c) 2014年 Tap Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#define kHomeCommiutedData @"diaobao.homepage.communited_%@"//首页信息，无圈子，无圈子
#define kHomePageRefreshTimeInterval 60*60 //a hour
#define kLastCommnutedSelected @"diaobao.last.commnutedSelected"
#define kLastCommnunitedSaveTime @"diaobiao.homepage.savetime_%d"

#define kHomePageRecomData @"diaobao.homepage.recom_%d"
#define kHomePageTopData @"diaobao.homepage.top_%d"


//communited
#define kComHomeMyComm_uid @"diaobao.com.home.my_%d" //未登录用户 -1；
#define kComHomeRecomComm_uid @"diaobao.com.home.recom_%d"
#define kComHomeAllComm_uid @"diaobao.com.home.all_%d"
#define kComeHomeSaveTime_uid @"diaobao.com.home.savetime_%d" //保存的是NSInterger
#define kComuHomeRefreshTimeInterval 60*60 //a hour
#define kUserAttentions_uid @"diaobao.com.user.attentions_%d"

#define kComuCateRecomCommu_ComuType @"diaobao.comu.recom.cat_%d"
#define kComuCateAllCommu_ComuType @"diaobao.comu.all.cat_%d"
#define kComeCateAllSaveTime_ComuType @"diaobao.com.all.savetime_%d"
#define kComuCateAllRefreshTimeInterval 5*60*60 //a hour

#define kComuDetailHead_comuid @"diaobao.comu.detail.head_%d"
#define kComuDetailALl_comuid @"diaobao.comu.detail.all_%d"
#define kComuDetailLast_comuid @"diaobao.comu.detail.last_%d"
#define kComuDetailSaveTime_comuid @"diaobao.com.detail.savetime_%d"
#define kComuCateDetailRefreshTimeInterval 0.5*60*60 //a hour

//TopicPage
#define kVideoTopicDetail_TopicId @"diaobao.topic.video.detail_%d"
#define kVideoTopicDetailRefreshTimeInterval 2*60*60 //a hour
#define kVideoTopicDetailSaveTime_TopicId @"diaobao.topic.video.detail.SaveTime_%d"


//private email
#define kPrivateMailDataSaveArray @"diaobao.private.mail.savearray"
#define kPrivateMailUpdateNum @"diaobao.private.mail.updataNum"
#define kPrivateMailUserId @"diaobao.private.mail.user.id"

#define kPrivateUserChatUpdate_useId_friendId @"diaobao.private.mail.chat.update.uid_%d.firendid_%d" //
#define kPrivateUserChatDataArray_useId_friendId @"diaobao.private.mail.chat.dataArray.uid_%d.firendid_%d" //


@interface WMUserDefault : NSObject

+(int)intValueForKey:(NSString *)key;
+(void)setIntValue:(int)value forKey:(NSString *)key;

+(CGFloat)floatValueForKey:(NSString *)key;
+(void)setFloatVaule:(CGFloat)value forKey:(NSString *)key;

+(BOOL)BoolValueForKey:(NSString *)key;
+(void)setBoolVaule:(BOOL)value forKey:(NSString *)key;

+(id)objectValueForKey:(NSString *)key;
+(void)setObjectValue:(id)value forKey:(NSString *)key;


+(void)setArray:(NSArray *)array forKey:(NSString *)key;
+ (NSArray *)arrayForKey:(NSString *)key;

@end
