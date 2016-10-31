//
//  ViewController.m
//  BabySleep
//
//  Created by Michael on 16/6/26.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "ViewController.h"

#import "SliderViewController.h"

#import "TFLargerHitButton.h"

#import "MptTableHeadView.h"

#import "CartoonHeadView.h"
#import "ShareAlertView.h"
#import "SetEndTimeView.h"
#import "TouchAnimationView.h"
#import "TouchInsideAnimationView.h"

#import "MusicCell.h"

#import "AudioTask.h"

#import "WMUserDefault.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<HeadViewDelegate,HeadViewDataSource,UITableViewDelegate,UITableViewDataSource,SetEndTimeViewDelegate>
{
    AVAudioPlayer *player;
}

@property (nonatomic , strong) UIButton *playBtn;

@property (nonatomic , strong) MptTableHeadView *tableheadView;

@property (nonatomic , strong) UIView *progressView;

@property (nonatomic , strong) NSMutableArray *picArray;

@property (nonatomic , strong) NSMutableArray *titleImgArray;

@property (nonatomic , strong) NSMutableArray *musicArray;

@property (nonatomic , strong) NSMutableArray *volumArray;

@property (nonatomic , assign) NSInteger playTime;

@property (nonatomic , assign) NSInteger currentPlayTime;

@property (nonatomic , strong) UILabel *currentTime;

@property (nonatomic , strong) UILabel *totalTime;

@property (nonatomic , assign) NSInteger musicIndex;

@property (nonatomic , assign) NSInteger selectIndex;

@property (nonatomic , assign) BOOL firstSelect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = HexRGB(0xDBF4FF);
    
    [self resetSelectMusic];
    
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    bgView.frame = self.view.bounds;
    [self.view addSubview:bgView];
    
    self.picArray = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7", nil];
    self.titleImgArray = [NSMutableArray arrayWithObjects:NSLocalizedString(@"xjnm", nil),NSLocalizedString(@"nyqc", nil),NSLocalizedString(@"xnqc", nil),NSLocalizedString(@"xycm", nil),NSLocalizedString(@"wsyp", nil),NSLocalizedString(@"ywgh", nil),NSLocalizedString(@"bl", nil),NSLocalizedString(@"sd", nil),NSLocalizedString(@"ls", nil),NSLocalizedString(@"xy", nil),NSLocalizedString(@"my", nil),NSLocalizedString(@"hlfl", nil), nil];
    self.musicArray = [NSMutableArray arrayWithObjects:@"xjnm",@"nyqc",@"xnqc",@"xycm",@"wsyp",@"ywgh",@"bl",@"sd",@"ls",@"xy",@"my",@"hlfl", nil];
    self.volumArray = [NSMutableArray array];
    
    for (int i = 0; i < 12; i ++) {
        [self.volumArray addObject:@"0.5"];
    }

    TFLargerHitButton *leftBtn = [[TFLargerHitButton alloc] initWithFrame:CGRectMake(15, 35, 15, 15)];
    [leftBtn setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(goMenuView:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setAdjustsImageWhenHighlighted:NO];
    [self.view addSubview:leftBtn];
    
    NSString *playMins = [WMUserDefault objectValueForKey:@"playtime"];
    
    BOOL wxInstalled = [WMUserDefault BoolValueForKey:@"WXInstalled"];
    
    if (wxInstalled && playMins.integerValue != 12) {
        TFLargerHitButton *rightBtn = [[TFLargerHitButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 19 - 15, 32, 19, 20)];
        [rightBtn setImage:[UIImage imageNamed:@"Cherry"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setAdjustsImageWhenHighlighted:NO];
        rightBtn.tag = TABLEVIEW_BEGIN_TAG * 100;
        [self.view addSubview:rightBtn];
    }

    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH - 71.35) * 0.5, 35, 71.58, 17.34)];
    titleView.image = [UIImage imageNamed:NSLocalizedString(@"momsleep", nil)];
    [self.view addSubview:titleView];
    
    CGFloat scrollViewY = 98;
    if (SCREENWIDTH == 414) {
        scrollViewY = 123;
    }
    
    scrollViewY = 69;
    if (SCREENWIDTH == 375) {
        scrollViewY = 71;
    }else if (SCREENWIDTH == 414) {
        scrollViewY = 78;
    }
    
    self.tableheadView = [[MptTableHeadView alloc] initWithFrame:CGRectMake(0, scrollViewY, SCREENWIDTH, 230) Type:MptTableHeadViewOther];
    self.tableheadView.dataSource = self;
    self.tableheadView.delegate = self;
    
    [self.view addSubview:self.tableheadView];

    TFLargerHitButton *clockBtn = [[TFLargerHitButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 31, CGRectGetMaxY(self.tableheadView.frame) - 20, 18, 19)];
    [clockBtn setImage:[UIImage imageNamed:@"time"] forState:UIControlStateNormal];
    [clockBtn addTarget:self action:@selector(setEndTime:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clockBtn];
    
    UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - 98 * SCREENWIDTH / 375.0, SCREENWIDTH, 98 * SCREENWIDTH / 375.0)];
    shadow.image = [UIImage imageNamed:@"shadow_bottom"];
    shadow.transform = CGAffineTransformRotate(shadow.transform, M_PI);
    [self.view addSubview:shadow];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableheadView.frame) + 20, SCREENWIDTH, SCREENHEIGHT - CGRectGetMaxY(self.tableheadView.frame) - 20)];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tag = TABLEVIEW_BEGIN_TAG * 10;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 82)];
    tableView.tableFooterView = footView;
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(tableView.frame), SCREENWIDTH, 1)];
    line.backgroundColor = HexRGB(0xF0A6FF);
    [self.view addSubview:line];
    
    scrollViewY = 506;
    if (SCREENWIDTH == 375) {
        scrollViewY = 605;
    }else if (SCREENWIDTH == 414) {
        scrollViewY = 674;
    }

    UIButton *adBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [adBtn setImage:[UIImage imageNamed:NSLocalizedString(@"MotherSleepAdsImage", nil)] forState:UIControlStateNormal];
    adBtn.frame = CGRectMake(SCREENWIDTH * 0.5 - 139, scrollViewY, 278, 62);
    [adBtn addTarget:self action:@selector(goOtherAppDownload) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:adBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetSelectMusic) name:@"resetSelectMusic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:@"reloadTableView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fadeShareView) name:@"fadeShareView" object:nil];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];//创建单例对象并且使其设置为活跃状态.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:nil];//设置通知
}

//通知方法的实现
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            //            tipWithMessage(@"耳机插入");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            [self stopMusic];
            [self resetSelectMusic];
            [self reloadTableView];
            //            tipWithMessage(@"耳机拔出，停止播放操作");
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            //            tipWithMessage(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadTableView];
}

-(void)goMenuView:(id)sender
{
    [[SliderViewController sharedSliderController] leftItemClick];
}

- (void)goOtherAppDownload
{
    //跳转宝贝快睡
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1128178648?mt=8"]];
}

-(void)setEndTime:(id)sender
{
    SetEndTimeView *endTimeView = [[SetEndTimeView alloc] initWithFrame:self.view.frame];
    endTimeView.delegate = self;
    [self.view addSubview:endTimeView];
    
    [endTimeView showView];
}

-(void)share:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    [self touchAnimationWithBtn:button];
    
    ShareAlertView *alertView = [[ShareAlertView alloc] initWithFrame:self.view.frame];
    alertView.tag = TABLEVIEW_BEGIN_TAG * 20;
    [self.view addSubview:alertView];
    
    [alertView showView];
}

-(void)resetSelectMusic
{
    self.selectIndex = -1;
    self.firstSelect = YES;
}

-(void)reloadTableView
{
    UITableView *table = (UITableView *)[self.view viewWithTag:TABLEVIEW_BEGIN_TAG * 10];
    
    ShareAlertView *alert = (ShareAlertView *)[self.view viewWithTag:TABLEVIEW_BEGIN_TAG * 20];

    if (table && [table isKindOfClass:[UITableView class]]) {
        [table reloadData];
    }
    
    if (alert) {
        [alert fadeView];
    }
}

- (void)fadeShareView
{
    UIButton *btn = (UIButton *)[self.view viewWithTag:TABLEVIEW_BEGIN_TAG * 100];
    if (btn) {
        btn.hidden = YES;
    }
}

-(void)jumpBtnAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    [self touchAnimationWithBtn:button];
    
    UIButton *btn = (UIButton *)sender;
    
    [self.tableheadView scrollWithType:btn.tag - TABLEVIEW_BEGIN_TAG];
}

- (void)touchAnimationWithBtn:(UIButton *)button
{
    TouchAnimationView *view = [[TouchAnimationView alloc] initWithFrame:CGRectMake(button.center.x - 22, button.center.y - 22, 44, 44)];
    [self.view addSubview:view];
    
    TouchInsideAnimationView *insideView = [[TouchInsideAnimationView alloc] initWithFrame:CGRectMake(button.center.x - 4, button.center.y - 4, 8, 8)];
    [self.view addSubview:insideView];
    
    [view disappearAnimation];
    [insideView disappearAnimation];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[WMUserDefault objectValueForKey:@"playtime"] integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *articlIdentifier = @"article";
    static NSString *musicIdentifier = @"music";
    
    if (indexPath.row >= [self.musicArray count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:articlIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:articlIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    
    MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:musicIdentifier];
    if (cell == nil) {
        cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:musicIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    [cell configureWithName:self.titleImgArray[indexPath.row] volum:self.volumArray[indexPath.row] selected:(self.selectIndex == indexPath.row)];
    
    cell.VolumValueChange = ^(CGFloat angle){
        [[AudioTask shareAudioTask] setPlayVolum:angle];
        [self.volumArray replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"%f",angle]];
    };

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0f;
    
    if (indexPath.row >= [self.musicArray count]) {
        return height;
    }
    
    return 82;
}

#pragma mark
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectIndex != indexPath.row) {
        NSInteger lastSelect = self.selectIndex;
        
        self.selectIndex = indexPath.row;
        
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:lastSelect inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if (!self.firstSelect) {
            [self.tableheadView scrollWithType:lastSelect < indexPath.row ? 1 : 0];
        }
        
        [self stopMusic];
        
        [[AudioTask shareAudioTask] setVolum:[self.volumArray[indexPath.row] floatValue]];
        
        [self playMusicWithIndex:self.selectIndex];
        
        self.firstSelect = NO;
    }else{
        [self resetSelectMusic];
        
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self stopMusic];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark SetEndTimeViewDelegate
- (void)confirmEndTimeWithDate:(NSDate *)date
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    NSInteger timeDelay = [date timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
    
    [self performSelector:@selector(stopMusic) withObject:nil afterDelay:timeDelay];
}
#pragma mark headview datasource delegate
- (NSUInteger)numberOfItemFor:(MptTableHeadView *)scrollView {
    return [self.picArray count];
}

- (MptTableHeadCell *)cellViewForScrollView:(MptTableHeadView *)scrollView frame:(CGRect)frame AtIndex:(NSUInteger)index {
    static NSString *indentif = @"headCell";
    CartoonHeadView *cell = (CartoonHeadView *)[scrollView dequeueCellWithIdentifier:indentif];
    if (!cell) {
        cell = [[CartoonHeadView alloc] initWithFrame:frame withIdentifier:indentif];
    }
    id objc = nil;
    if (self.picArray.count > index) {
        objc = [self.picArray objectAtIndex:index];
    } else {
        return cell;
    }
    
    if ([objc isKindOfClass:[NSString class]]) {
        NSString *imgUrl = (NSString *)objc;
        cell.imageView.image = [UIImage imageNamed:imgUrl];
    }
    
    return cell;
}

- (void)tableHeadView:(MptTableHeadView *)headView didSelectIndex:(NSUInteger)index {
    return;
}

- (void)tableHeadView:(MptTableHeadView *)headView didScrollToIndex:(NSUInteger)index
{
    
}

- (void)playMusicWithIndex:(NSInteger)index
{
    NSString *musicName = self.musicArray[index];
    
    //1.音频文件的url路径
    NSString *musicFilePath= [[NSBundle mainBundle] pathForResource:musicName ofType:@"mp3"];
    
    [self audioPlayWithPath:[[NSURL alloc] initFileURLWithPath:musicFilePath]];
}

-(void)audioPlayWithPath:(NSURL *)url
{
    NSString *playMins = [WMUserDefault objectValueForKey:@"playtime"];
    
    self.playTime = playMins.integerValue * 60;
    
    [[AudioTask shareAudioTask] setUrl:url];
    [[AudioTask shareAudioTask] startTaskWithTyep:backgroundTask];
}

- (void)stopMusic
{
    [[AudioTask shareAudioTask] stopTaskWithType:backgroundTask];
}

- (void)updateProgressView
{
    CGFloat percent = self.currentPlayTime * 1.0 / self.playTime;
    
    CGRect frame = self.progressView.frame;
    frame.size.width = percent * SCREENWIDTH;
    self.progressView.frame = frame;
    
    self.currentTime.text = [self timeStringWith:self.currentPlayTime];
}

- (NSString *)timeStringWith:(NSInteger)time
{
    return [NSString stringWithFormat:@"%@%ld:%@%ld",time/60 > 9 ? @"" : @"0",time/60,time%60 > 9 ? @"" : @"0",time%60];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
