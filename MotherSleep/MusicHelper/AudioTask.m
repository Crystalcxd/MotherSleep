//
//  AudioTask.m
//  FVGravityView
//
//  Created by mac on 15/9/8.
//
//

#import "AudioTask.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h> 

static AudioTask *audioTask;
@implementation AudioTask
{
    //检测后台Task运行剩余时间是否小于60;
    NSTimer *backgroundTimeRemainingTimer_;
    
    //当前系统音量(闹铃响起前记录)
    CGFloat systemVolumBeforeAlarmRang_;
    
    BOOL isPlaying;
}

+ (id)shareAudioTask
{
    @synchronized(self)
    {
        if (audioTask == nil)
        {
            audioTask = [[[self class]alloc]init];
        }
    }
    return audioTask;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    if (audioTask == nil)
    {
        audioTask = [super allocWithZone:zone];
    }
    return audioTask;
}

-(id) init
{
    self = [super init];
    if(self)
    {
        bgTask = UIBackgroundTaskInvalid;
        expirationHandler =nil;
    }
    
    return  self;
}

- (void)startTaskWithTyep:(taskType)type
{
    self.currentTaskType = type;
    [self initBackgroudTask];
    if (backgroundTimeRemainingTimer_)
    {
        if ([backgroundTimeRemainingTimer_ isValid])
        {
            [backgroundTimeRemainingTimer_ invalidate];
        }
        backgroundTimeRemainingTimer_ = nil;
    }
    
    backgroundTimeRemainingTimer_ = [NSTimer scheduledTimerWithTimeInterval:20
                                                                      target:self
                                                                    selector:@selector(checkBgTask)
                                                                    userInfo:nil
                                                                     repeats:YES];
}

- (void)checkBgTask
{
    if ([[UIApplication sharedApplication] backgroundTimeRemaining] < 61.0)
    {
        [self initBackgroudTask];
        NSLog(@"重启后台Task*******");
    }
}

- (void)volumeReduce
{
    if (player && player.volume > 0.01)
    {
        player.volume -= 0.005;
    }
}

- (void)alarmSoundGradualChange
{

}

- (void)stopTaskWithType:(taskType)type
{
    if (type != self.currentTaskType)
    {
        return;
    }
    
    switch (type)
    {
        case backgroundTask:
        {
            [self stopAudio];
            break;
        }
        case sleepAidTask:
        case alarmTask:
        case positionTestTask:
        {
            self.currentTaskType = backgroundTask;
            player.volume = 0;
            [self startTaskWithTyep:backgroundTask];
            break;
        }
            
        default:
            break;
    }
}

- (void)stopAll
{
    [self stopAudio];
}

-(void) initBackgroudTask
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
//                       if([self running])
//                       {
//                           [self stopAudio];
//                       }
//                       
//                       while([self running])
//                       {
//                           [NSThread sleepForTimeInterval:0.5]; //wait for finish
//                       }
                       [self playAudio];
                   });
}


- (void) audioInterrupted:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSNumber *interuptionType = [interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey];
//    if([interuptionType intValue] == 1)
//    {
////        [self initBackgroudTask];
//        [player play];
//    }
    
    //********
    
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        NSLog(@"Interruption notification received %@!", notification);
        
        //Check to see if it was a Begin interruption
        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]])
        {
            NSLog(@"Interruption began!");
            
        } else if([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeEnded]])
        {
            NSLog(@"Interruption ended!");
            // Resume playing the audio.
//            [player play];
            [self initBackgroudTask];

            
        }
    }
}



-(void) playAudio
{
    
     UIApplication * app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioInterrupted:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    expirationHandler = ^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
        [player stop];
        isPlaying = NO;
        NSLog(@"###############Background Task Expired.");
    };
    bgTask = [app beginBackgroundTaskWithExpirationHandler:expirationHandler];
    
//    [self jhh_setUpAudioSession];

    dispatch_async(dispatch_get_main_queue(), ^{
        
        //        OSStatus osStatus;
        NSError * error;

        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error:nil];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance]setDelegate:self];

        //******
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:&error];
        int numberOfLoops = -1;
        player.delegate = self;
        player.volume = self.volum;
        player.numberOfLoops = numberOfLoops; //Infinite
        [player prepareToPlay];
        [player play];
        
        isPlaying = YES;
    });
}

- (void)setSystemVolume:(CGFloat)volume
{
    MPVolumeView *slide = [MPVolumeView new];
    UISlider *volumeViewSlider;
    
    for (UIView *view in [slide subviews])
    {
        if ([[[view class] description] isEqualToString:@"MPVolumeSlider"])
        {
            volumeViewSlider = (UISlider *) view;
//            volumeViewSlider.value = volume;
            [volumeViewSlider setValue:volume animated:NO];
        }
    }
}

- (void)setPlayVolum:(CGFloat)volum
{
    player.volume = volum;
}

-(void) stopAudio
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    if(player != nil && [player isPlaying])
    {
        [player stop];
//        player = nil;
        
        isPlaying = NO;
    }
    
//    if(bgTask != UIBackgroundTaskInvalid)
//    {
//        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
//        bgTask=UIBackgroundTaskInvalid;
//    }
}

- (void)setVolumToZero:(BOOL)flag
{
    if (flag)
    {
        if (player)
        {
            player.volume = 0;
        }
    }
    else
    {
        if (player)
        {
            switch (self.currentTaskType)
            {
                case backgroundTask:
                {
                    player.volume = 0;
                    break;
                }
                case sleepAidTask:
                {
//                    player.volume = [self.currentAssist.volum floatValue] / 16.0;
                    break;
                }
                case alarmTask:
                {
                    break;
                }
                default:
                    break;
            }
        }
    }
}


-(BOOL) running
{
    if(bgTask == UIBackgroundTaskInvalid)
    {
        return FALSE;
    }
    return TRUE;
}

-(void) stopBackgroundTask
{
    [self stopAudio];
}

- (CGFloat)getCurrentSystemVolum
{
    MPVolumeView *slide = [MPVolumeView new];
    UIViewController *keyVC = [self appRootViewController];
    [keyVC.view addSubview:slide];
    slide.frame = CGRectMake(5, 5, 10, 10);
    __block UISlider *volumeViewSlider;
    __block float currentVolum = 0.5;
    
    double delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (UIView *view in [slide subviews])
        {
            if ([[[view class] description] isEqualToString:@"MPVolumeSlider"])
            {
                volumeViewSlider = (UISlider *) view;
                systemVolumBeforeAlarmRang_ = volumeViewSlider.value;
                [slide removeFromSuperview];
            }
        }
    });

    return currentVolum;
}

- (void)recoverSystemVolumAfterAlarmClose
{
    [self setSystemVolume:systemVolumBeforeAlarmRang_];
}

#pragma mark -Private

- (NSString *)getDocumentPath
{
    NSArray *docPathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = docPathArr[0];//Documents路径;
    return documentPath;
}
- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController)
    {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

#pragma mark - 
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (positionTestTask == self.currentTaskType)
    {
        [self startTaskWithTyep:backgroundTask];
    }
}

#pragma mark -
- (void)beginInterruption  /* something has caused your audio session to be interrupted */
{
    //有打断就暂停播放
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetSelectMusic" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableView" object:nil];
    
    //区分前台后台,否则总有一种情况调不起音频,原因未知
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
//        [self jhh_setUpAudioSession];
        //后台
        if (isPlaying) {
//            [player play];
        }
    }
    else
    {
//        [self initBackgroudTask];
    }
    NSLog(@">>>>>BeginInterruption");
}

- (void)endInterruptionWithFlags:(NSUInteger)flags
{
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
//        [self jhh_setUpAudioSession];
        //后台
        if (isPlaying) {
//            [player play];
        }
    }
    else
    {
//        [self initBackgroudTask];
    }
    NSLog(@">>>>>endInterruptionWithFlags");
}

/**
 *  设置AVAudioSession
 */
- (void)jhh_setUpAudioSession
{
    // AudioSession functions are deprecated from iOS 7.0, so prefer using AVAudioSession
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    if ([audioSession respondsToSelector:@selector(setCategory:withOptions:error:)]) {
        NSError *activeSetError = nil;
        [audioSession setActive:YES
                          error:&activeSetError];
        
        
        NSError *categorySetError = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayback
                      withOptions:AVAudioSessionCategoryOptionMixWithOthers
                            error:&categorySetError];
        
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"    // supress deprecated warning
        
        // Initialize audio session
        AudioSessionInitialize
        (
         NULL, // Use NULL to use the default (main) run loop.
         NULL, // Use NULL to use the default run loop mode.
         NULL, // A reference to your interruption listener callback function.
         // See “Responding to Audio Session Interruptions” in Apple's "Audio Session Programming Guide" for a description of how to write
         // and use an interruption callback function.
         NULL  // Data you intend to be passed to your interruption listener callback function when the audio session object invokes it.
         );
        
        // Activate audio session
        OSStatus activationResult = 0;
        activationResult          = AudioSessionSetActive(true);
        
        
        // Set up audio session category to kAudioSessionCategory_MediaPlayback.
        // While playing sounds using this session category at least every 10 seconds, the iPhone doesn't go to sleep.
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback; // Defines a new variable of type UInt32 and initializes it with the identifier
        // for the category you want to apply to the audio session.
        AudioSessionSetProperty
        (
         kAudioSessionProperty_AudioCategory, // The identifier, or key, for the audio session property you want to set.
         sizeof(sessionCategory),             // The size, in bytes, of the property value that you are applying.
         &sessionCategory                     // The category you want to apply to the audio session.
         );
        
        // Set up audio session playback mixing behavior.
        // kAudioSessionCategory_MediaPlayback usually prevents playback mixing, so we allow it here. This way, we don't get in the way of other sound playback in an application.
        // This property has a value of false (0) by default. When the audio session category changes, such as during an interruption, the value of this property reverts to false.
        // To regain mixing behavior you must then set this property again.
        
        // Always check to see if setting this property succeeds or fails, and react appropriately; behavior may change in future releases of iPhone OS.
        OSStatus propertySetError = 0;
        UInt32 allowMixing        = true;
        
        propertySetError = AudioSessionSetProperty
        (
         kAudioSessionProperty_OverrideCategoryMixWithOthers, // The identifier, or key, for the audio session property you want to set.
         sizeof(allowMixing),                                 // The size, in bytes, of the property value that you are applying.
         &allowMixing                                         // The value to apply to the property.
         );
        
        
#pragma clang diagnostic pop
    }
}

@end
