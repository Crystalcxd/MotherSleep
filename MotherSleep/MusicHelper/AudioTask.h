//
//  AudioTask.h
//  FVGravityView
//
//  Created by mac on 15/9/8.
/*
    功能:1.播放催眠/闹铃音频
        2.播放无声音频保存程序长驻后台
 
 
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef enum
{
    //后台无声运行
    backgroundTask = 0,
    
    //睡眠辅助音乐
    sleepAidTask = 1,
    
    //闹铃音乐
    alarmTask = 2,
    
    //手机位置摆放测试
    positionTestTask = 3,
    
}taskType;

@interface AudioTask : NSObject <AVAudioPlayerDelegate,AVAudioSessionDelegate>
{
    __block UIBackgroundTaskIdentifier bgTask;//任务名称
    __block dispatch_block_t expirationHandler;
    __block AVAudioPlayer *player;
}

@property (nonatomic,assign)float volum;

@property (nonatomic,assign)BOOL isNeedSound;
@property (nonatomic,assign)taskType currentTaskType;

@property (nonatomic,strong)NSURL *url;

+ (id)shareAudioTask;


- (void)startTaskWithTyep:(taskType)type;

/**
 *  停止特定类型音频
 *
 *  @param type --
 */
- (void)stopTaskWithType:(taskType)type;

/**
 *  停止一切类型音频播放
 */
- (void)stopAll;

- (void)setVolumToZero:(BOOL)flag;

/**
 *  音量减小(供手机位置摆放测试调用,实现音效渐弱)
 */
- (void)volumeReduce;

/**
 *  闹铃声渐强(响起后2分钟内音量由0增至用户设定量)
 */
- (void)alarmSoundGradualChange;

/**
 *  设置手机系统音量
 *
 *  @param volume --
 */
- (void)setSystemVolume:(CGFloat)volume;

/**
 *  设置当前播放音量
 *
 *  @param volume --
 */
- (void)setPlayVolum:(CGFloat)volum;
/**
 *  获取系统音量
 *
 *  @return 当前系统音量
 */
- (CGFloat)getCurrentSystemVolum;

/**
 *  闹铃关闭后,恢复系统音量设置.
 */
- (void)recoverSystemVolumAfterAlarmClose;

@end