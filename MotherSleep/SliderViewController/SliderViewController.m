//
//  SliderViewController.m
//  LeftRightSlider
//
//  Created by heroims on 13-11-27.
//  Copyright (c) 2013年 heroims. All rights reserved.
//

#import "SliderViewController.h"
//#import "ShakeViewController.h"
//#import "IFAccelerometer.h"
//#import "Define.h"
static CGFloat kBlackCoverMaxAlpha = 0.6f;


typedef NS_ENUM(NSInteger, RMoveDirection) {
    RMoveDirectionLeft = 0,
    RMoveDirectionRight
};

@interface SliderViewController ()<UIGestureRecognizerDelegate>{
    UIView *_mainContentView;
    UIView *_leftSideView;
    UIView *_rightSideView;
    UIView *_blackCoverView;
    
    NSMutableDictionary *_controllersDict;
    
    UITapGestureRecognizer *_tapGestureRec;
    UIPanGestureRecognizer *_panGestureRec;
    UIPanGestureRecognizer *_panOnBlackCoverViewGestureRec;
    
    BOOL _showLeftSideView;
    BOOL _showRightSideView;
}

@end

@implementation SliderViewController

#if __has_feature(objc_arc)
#else
-(void)dealloc{
    [_mainContentView release];
    [_leftSideView release];
    [_rightSideView release];
    [_blackCoverView release];
    
    [_controllersDict release];
    
    [_tapGestureRec release];
    [_panGestureRec release];
    [_panOnBlackCoverViewGestureRec release];
    
    [_LeftVC release];
    [_RightVC release];
    [_MainVC release];
    [super dealloc];
}
#endif

+ (SliderViewController*)sharedSliderController
{
    static SliderViewController *sharedSVC;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSVC = [[self alloc] init];
    });
    
    return sharedSVC;
}

- (id)init{
    if (self = [super init]){
        _LeftSContentOffset=0.618667*SCREENWIDTH;
        _RightSContentOffset=0.618667*SCREENWIDTH;
        _LeftSContentScale=1.0;
        _RightSContentScale=1.0;
        _LeftSJudgeOffset=100;
        _RightSJudgeOffset=100;
        _LeftSOpenDuration=0.2;
        _RightSOpenDuration=0.2;
        _LeftSCloseDuration=0.3;
        _RightSCloseDuration=0.3;
        
        _showLeftSideView = NO;
        _showRightSideView = NO;
        _canMoveWithGesture = NO;
    }
        
    return self;
}

- (void)viewDidLoad
{
    NSAssert((_mainVCClassName && (_mainVCClassName.length > 0)), @"\n\n\n没有设置主ViewController类名\n\n");
    
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=YES;

    _controllersDict = [NSMutableDictionary dictionary];
    
    [self initSubviews];
    
    [self initChildControllers:_LeftVC rightVC:_RightVC];
    
    [self showContentControllerWithModel:_mainVCClassName];
    
    _tapGestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSideBar)];
    _tapGestureRec.delegate=self;
    [_blackCoverView addGestureRecognizer:_tapGestureRec];
    _tapGestureRec.enabled = NO;
    
    _panGestureRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGesture:)];
//    [_mainContentView addGestureRecognizer:_panGestureRec];
    
    _panOnBlackCoverViewGestureRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGesture:)];
    [_blackCoverView addGestureRecognizer:_panOnBlackCoverViewGestureRec];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    NSArray *array = [_mainContentView subviews];
    
    NSInteger count = array.count;
    
    for (int i = 0; i < count; i++) {
        UIView *view = [array objectAtIndex:i];
        if (view.tag == TABLEVIEW_BEGIN_TAG) {
            UITableView *table = [view viewWithTag:TABLEVIEW_BEGIN_TAG * 40];
            
            if (table && [table isKindOfClass:[UITableView class]]) {
                [table reloadData];
            }
        }
    }
}

#pragma mark - Init

- (void)initSubviews
{
    _rightSideView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_rightSideView];
    
    _mainContentView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_mainContentView];

    CGRect frame = self.view.bounds;
    frame.origin.x = -SCREENWIDTH;
    
    _leftSideView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:_leftSideView];

    _blackCoverView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_blackCoverView];
    self.view.clipsToBounds = NO;
    _blackCoverView.backgroundColor = HexRGB(0xFCDEE9);
    _blackCoverView.hidden = YES;
    _blackCoverView.layer.shadowColor = RGBA(165, 118, 196, 0.65).CGColor;
    _blackCoverView.layer.shadowOffset = CGSizeMake(-2, 0);
    
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, SCREENHEIGHT)];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];  // 设置渐变效果
    gradientLayer.bounds = shadowView.bounds;
    gradientLayer.borderWidth = 0;
    
    gradientLayer.frame = shadowView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:
                             (id)[RGBA(165, 118, 196, 0.65) CGColor],
                             (id)[[UIColor clearColor] CGColor], nil];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 0);
    
    [shadowView.layer insertSublayer:gradientLayer atIndex:0];
    
    [_blackCoverView addSubview:shadowView];
}

- (void)initChildControllers:(UIViewController*)leftVC rightVC:(UIViewController*)rightVC
{
    if (leftVC)
    {
        [self addChildViewController:leftVC];
        leftVC.view.frame=CGRectMake(0, 0, leftVC.view.frame.size.width, leftVC.view.frame.size.height);
        [_leftSideView addSubview:leftVC.view];
        
        _showLeftSideView = YES;
    }
    else
    {
        _showLeftSideView = NO;
    }
    
    if (rightVC)
    {
        [self addChildViewController:rightVC];
        rightVC.view.frame=CGRectMake(0, 0, rightVC.view.frame.size.width, rightVC.view.frame.size.height);
        [_rightSideView addSubview:rightVC.view];
        
        _showRightSideView = YES;
    }
    else
    {
        _showRightSideView = NO;
    }
}

#pragma mark - Actions

- (void)showContentControllerWithModel:(NSString *)className
{
    [self closeSideBar];
    
    if ([self.MainVC isKindOfClass:NSClassFromString(className)]) {
        return;
    }
    
    UIViewController *controller = _controllersDict[className];
    if (!controller)
    {
        Class c = NSClassFromString(className);
        
#if __has_feature(objc_arc)
        controller = [[c alloc] init];
#else
        controller = [[[c alloc] init] autorelease];
#endif
        [_controllersDict setObject:controller forKey:className];
    }
    
    if (_mainContentView.subviews.count > 0)
    {
        UIView *view = [_mainContentView.subviews firstObject];
        [view removeFromSuperview];
    }
    
    controller.view.frame = _mainContentView.frame;
    controller.view.tag = TABLEVIEW_BEGIN_TAG;
    [_mainContentView addSubview:controller.view];
    
    self.MainVC=controller;
}

- (void)leftItemClick
{
//    [[IFAccelerometer shareAccelerometer] removeObserver];

    if (_showLeftSideView)
    {
        CGAffineTransform conT = [self transformWithDirection:RMoveDirectionRight];
        
        [self.view sendSubviewToBack:_rightSideView];
        [self configureViewShadowWithDirection:RMoveDirectionRight];
        
        [UIView animateWithDuration:_LeftSOpenDuration
                         animations:^{
                             _leftSideView.transform = conT;
                             
                             _blackCoverView.hidden = NO;
                             _blackCoverView.alpha = kBlackCoverMaxAlpha;
                             _blackCoverView.transform = conT;
                         }
                         completion:^(BOOL finished) {
                             _tapGestureRec.enabled = YES;
                         }];
    }else{}
}

- (void)rightItemClick
{
//    [[IFAccelerometer shareAccelerometer] removeObserver];

    if (_showRightSideView)
    {
        CGAffineTransform conT = [self transformWithDirection:RMoveDirectionLeft];
        
        [self.view sendSubviewToBack:_leftSideView];
        [self configureViewShadowWithDirection:RMoveDirectionLeft];
        
        [UIView animateWithDuration:_RightSOpenDuration
                         animations:^{
                             _mainContentView.transform = conT;
                             
                             _blackCoverView.hidden = NO;
                             _blackCoverView.alpha = kBlackCoverMaxAlpha;
                             _blackCoverView.frame = _mainContentView.frame;
                         }
                         completion:^(BOOL finished) {
                             _tapGestureRec.enabled = YES;
                         }];
    }else{}
}

- (void)closeSideBar
{
//    if ([[SliderViewController sharedSliderController].MainVC isKindOfClass:[ShakeViewController class]]) {
//        [[IFAccelerometer shareAccelerometer] addOberser:[SliderViewController sharedSliderController].MainVC];
//    }

    CGAffineTransform oriT = CGAffineTransformIdentity;
    [UIView animateWithDuration:_mainContentView.transform.tx==_LeftSContentOffset?_LeftSCloseDuration:_RightSCloseDuration
                     animations:^{
                         _leftSideView.transform = oriT;
                         _blackCoverView.alpha = 0.0f;
                         _blackCoverView.transform = oriT;
                     }
                     completion:^(BOOL finished) {
                         _tapGestureRec.enabled = NO;
                         _blackCoverView.hidden = YES;
                     }];
}

- (void)moveViewWithGesture:(UIPanGestureRecognizer *)panGes
{
    if (!_canMoveWithGesture)
    {
        return;
    }else{}
    
    static CGFloat currentTranslateX;
    if (panGes.state == UIGestureRecognizerStateBegan)
    {
        currentTranslateX = _mainContentView.transform.tx;
    }
    if (panGes.state == UIGestureRecognizerStateChanged)
    {
        CGFloat transX = [panGes translationInView:_mainContentView].x;
        transX = transX + currentTranslateX;
        
        CGFloat sca;
        BOOL isTransformView = NO;
        CGFloat blackCoverAlpha = 0.0f;
        if ((transX > 0) && _showLeftSideView)
        {
            [self.view sendSubviewToBack:_rightSideView];
            [self configureViewShadowWithDirection:RMoveDirectionRight];
            
            if (_mainContentView.frame.origin.x < _LeftSContentOffset)
            {
                sca = 1 - (_mainContentView.frame.origin.x/_LeftSContentOffset) * (1-_LeftSContentScale);
            }
            else
            {
                sca = _LeftSContentScale;
            }
            blackCoverAlpha = MIN((transX/_LeftSContentOffset * kBlackCoverMaxAlpha), kBlackCoverMaxAlpha);
            isTransformView = YES;
        }
        else if ((transX < 0) && _showRightSideView)
        {
            [self.view sendSubviewToBack:_leftSideView];
            [self configureViewShadowWithDirection:RMoveDirectionLeft];
            
            if (_mainContentView.frame.origin.x > -_RightSContentOffset)
            {
                sca = 1 - (-_mainContentView.frame.origin.x/_RightSContentOffset) * (1-_RightSContentScale);
            }
            else
            {
                sca = _RightSContentScale;
            }
            blackCoverAlpha = MIN((-transX/_RightSContentOffset * kBlackCoverMaxAlpha), kBlackCoverMaxAlpha);
            isTransformView = YES;
        }
        else
        {
            sca = 0.0f;
            isTransformView = NO;
        }
        
        if (isTransformView)
        {
            CGAffineTransform transS = CGAffineTransformMakeScale(1.0, sca);
            CGAffineTransform transT = CGAffineTransformMakeTranslation(transX, 0);
            
            CGAffineTransform conT = CGAffineTransformConcat(transT, transS);
            
            _mainContentView.transform = conT;
            
            _blackCoverView.hidden = NO;
            _blackCoverView.alpha = blackCoverAlpha;
            _blackCoverView.frame = _mainContentView.frame;
        }else{}
    }
    else if (panGes.state == UIGestureRecognizerStateEnded)
    {
        CGFloat panX = [panGes translationInView:_mainContentView].x;
        CGFloat finalX = currentTranslateX + panX;
//        [[IFAccelerometer shareAccelerometer] removeObserver];
        if ((finalX > _LeftSJudgeOffset) && _showLeftSideView)
        {
            CGAffineTransform conT = [self transformWithDirection:RMoveDirectionRight];
            [UIView beginAnimations:nil context:nil];
            _mainContentView.transform = conT;
            
            _blackCoverView.alpha = kBlackCoverMaxAlpha;
            _blackCoverView.frame = _mainContentView.frame;
            
            [UIView commitAnimations];
            
            _tapGestureRec.enabled = YES;
            
            
            return;
        }
        if ((finalX < -_RightSJudgeOffset) && _showRightSideView)
        {
            CGAffineTransform conT = [self transformWithDirection:RMoveDirectionLeft];
            [UIView beginAnimations:nil context:nil];
            _mainContentView.transform = conT;
            
            _blackCoverView.alpha = kBlackCoverMaxAlpha;
            _blackCoverView.frame = _mainContentView.frame;
            
            [UIView commitAnimations];
            
            _tapGestureRec.enabled = YES;
            return;
        }
        else
        {
//            if ([[SliderViewController sharedSliderController].MainVC isKindOfClass:[ShakeViewController class]]) {
//                [[IFAccelerometer shareAccelerometer] addOberser:[SliderViewController sharedSliderController].MainVC];
//            }
            CGAffineTransform oriT = CGAffineTransformIdentity;
            [UIView beginAnimations:nil context:nil];
            _mainContentView.transform = oriT;

            [UIView commitAnimations];
            
            _tapGestureRec.enabled = NO;
            _blackCoverView.hidden = YES;
        }
    }
}

#pragma mark -

- (CGAffineTransform)transformWithDirection:(RMoveDirection)direction
{
    CGFloat translateX = 0;
    CGFloat transcale = 0;
    switch (direction) {
        case RMoveDirectionLeft:
            translateX = -_RightSContentOffset;
            transcale = _RightSContentScale;
            break;
        case RMoveDirectionRight:
            translateX = _LeftSContentOffset;
            transcale = _LeftSContentScale;
            break;
        default:
            break;
    }
    
    CGAffineTransform transT = CGAffineTransformMakeTranslation(translateX, 0);
    CGAffineTransform scaleT = CGAffineTransformMakeScale(1.0, transcale);
    CGAffineTransform conT = CGAffineTransformConcat(transT, scaleT);
    
    return conT;
}

- (void)configureViewShadowWithDirection:(RMoveDirection)direction
{
    CGFloat shadowW;
    switch (direction)
    {
        case RMoveDirectionLeft:
            shadowW = 2.0f;
            break;
        case RMoveDirectionRight:
            shadowW = -2.0f;
            break;
        default:
            break;
    }
    
    _mainContentView.layer.shadowOffset = CGSizeMake(2, 0);
    _mainContentView.layer.shadowColor = RGBA(165, 118, 196, 0.65).CGColor;
    _mainContentView.layer.shadowOpacity = 1.0f;
}



@end
