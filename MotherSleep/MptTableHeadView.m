//
//  MptTableHeadView.m
//  TVGontrol
//
//  Created by Kyle on 13-5-7.
//  Copyright (c) 2013年 MIPT. All rights reserved.
//

#import "MptTableHeadView.h"
#import "MptTableHeadCell.h"
#import "MptPageControl.h"

#import "Utility.h"

#define kPageControl_H 15
#define kAutoLoopIntervalS 8.0


@interface MptTouchScrollView : UIScrollView

@end


@implementation MptTouchScrollView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging)
        [self.nextResponder touchesEnded: touches withEvent:event];
    else
        [super touchesEnded: touches withEvent: event];
}

@end


@interface MptTableHeadView()<UIScrollViewDelegate>
{
    
}

@property (nonatomic, assign) BOOL arrawAnimation;
//@property (nonatomic, weak)  NSTimer *runloopTimer;
@property (nonatomic, strong) NSMutableArray *onsScreenTags;
@property (nonatomic, strong) NSMutableArray *onScreenCells;
@property (nonatomic, strong) NSMutableDictionary *saveCells;

- (void)loadViews;
- (void)queueContentCell:(UIImageView *)cell;

@end


@implementation MptTableHeadView
@synthesize scrollView = _scrollView;
@synthesize curPage = _curPage;

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;

@synthesize pageControl = _pageControl;

- (void)dealloc{
//    [self.runloopTimer invalidate];
//    self.runloopTimer = nil;
}

- (id)initWithFrame:(CGRect)frame Type:(NSInteger)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.onScreenCells = [NSMutableArray arrayWithCapacity:10];
        self.onsScreenTags = [NSMutableArray arrayWithCapacity:5];
        
        self.scrollView = [[MptTouchScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.delegate = self;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.bouncesZoom = NO;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.userInteractionEnabled = NO;
        [self.scrollView setContentOffset:CGPointZero];
        self.scrollView.showsHorizontalScrollIndicator = FALSE;
        self.scrollView.showsVerticalScrollIndicator = FALSE;
        [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.bounds)*3, CGRectGetHeight(self.bounds))];
        [self addSubview:self.scrollView];
        
        if (type == MptTableHeadViewUser) {
            self.pageControl = [[MptPageControl alloc] initWithFrame:CGRectMake(SCREENWIDTH*3/4, CGRectGetHeight(self.scrollView.frame)-kPageControl_H, SCREENWIDTH/4, kPageControl_H) Type:type];
        }else{
            self.pageControl = [[MptPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.scrollView.frame)-kPageControl_H, SCREENWIDTH, kPageControl_H) Type:type];
        }
        
        self.backArraw = [[UIImageView alloc] initWithFrame:CGRectMake(15, 164, 15, 38)];
        self.backArraw.image = [UIImage imageNamed:@"left"];
//        self.backArraw.hidden = YES;
        self.backArraw.alpha = 0.0;
        [self addSubview:self.backArraw];
        
        self.nextArraw = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH - 15 - 15, CGRectGetMinY(self.backArraw.frame), 15, 38)];
        self.nextArraw.image = [UIImage imageNamed:@"left"];
        self.nextArraw.alpha = 0.0;
        self.nextArraw.transform = CGAffineTransformRotate(self.nextArraw.transform, M_PI);

        [self addSubview:self.nextArraw];
//        [self addSubview:self.pageControl];
    }
    return self;
}
#pragma mark
#pragma mark datasource
- (void)setDataSource:(id<HeadViewDataSource>)dataSource{
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
    }
    
    [self reloadData];
}

#pragma mark
#pragma mark cell reuse
- (MptTableHeadCell *)dequeueCellWithIdentifier:(NSString *)identifier{
	if(self.saveCells){
		//找到了重用的
        NSMutableArray *arys = [self.saveCells objectForKey:identifier];
        if (arys && arys.count != 0) {
            MptTableHeadCell *cell = [arys lastObject];
            [arys removeLastObject];
            return cell;
        }
        return nil;
	}
	return nil;
}

- (void)queueContentCell:(MptTableHeadCell *)cell{
    if (!self.saveCells) {
        self.saveCells = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    NSString *identifier = cell.identifier;
    NSMutableArray *ary = [self.saveCells objectForKey:identifier];
    if (!ary) {
        ary = [NSMutableArray arrayWithCapacity:10];
    }
    [ary addObject:cell];
    [self.saveCells setObject:ary forKey:@"headCell"];
}

- (NSArray *)getDisplayImagesWithCurpage:(NSInteger)page { //在屏幕上的
    if (_total == 1) {
        [self.onsScreenTags removeAllObjects];
        [self.onsScreenTags addObject:[NSNumber numberWithInt:0]];
        return self.onsScreenTags;
    }
    
    NSInteger pre = [self validPageValue:page-1];
    NSInteger last = [self validPageValue:page+1];
    
    if([self.onsScreenTags count] != 0) [self.onsScreenTags removeAllObjects];
    
    [self.onsScreenTags addObject:[NSNumber numberWithInteger:pre]];
    [self.onsScreenTags addObject:[NSNumber numberWithInteger:page]];
    [self.onsScreenTags addObject:[NSNumber numberWithInteger:last]];
    
    return self.onsScreenTags;
}

- (NSInteger)validPageValue:(NSInteger)value {
    if(value == -1) value = _total-1;                   // value＝0为第一张，value = -1为前面一张
    if(value == _total ) value = 0;
    
    return value;
}

- (void)doAutoLoop{
    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame)*2, 0) animated:YES];
}

#pragma mark
#pragma mark private method
- (void)reloadData{
    
//    [self.runloopTimer invalidate];
//    self.runloopTimer = nil;
    
    for (MptTableHeadCell *cell in self.onScreenCells) {
        [cell viewWillDisappear];
        [cell removeFromSuperview];
        [cell viewDidDisappear];
    }
    [self.onScreenCells removeAllObjects];
    for (NSString *key in [self.saveCells allKeys]) {
        NSMutableArray *arys = [self.saveCells objectForKey:key];
        [arys removeAllObjects];
    }
    
    [self.saveCells removeAllObjects];
    
    _total = 0;
    _curPage = 0;
    
    if ([_dataSource respondsToSelector:@selector(numberOfItemFor:)]) {
        _total = [_dataSource numberOfItemFor:self];
    }
    self.pageControl.numberOfPages = _total;
    self.pageControl.currentPage = _curPage;
    if (_total == 0) { //have no item
        return; 
    }
    
    if (_total == 1) {
        self.scrollView.contentOffset = CGPointMake(0, 0);
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    }else if (_total == 2){
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame)*3, CGRectGetHeight(self.scrollView.frame));
    }else {
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame)*3, CGRectGetHeight(self.scrollView.frame));
    }
    
    [self loadViews];
    
    if (_total == 1) {
        return;
    }
//    self.runloopTimer = [NSTimer scheduledTimerWithTimeInterval:kAutoLoopIntervalS
//                                                                  target:self
//                                                                selector:@selector(doAutoLoop)
//                                                                userInfo:nil
//                                                                 repeats:YES];
}

- (void)stopAnimation
{
//    [self.runloopTimer invalidate];
//    self.runloopTimer = nil;
}

- (void)scrollWithType:(ScrollType)type
{
    if (type == ScrollTypeBack) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
        [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame)*2, 0) animated:YES];
    }
}

- (void)loadViews{
    [self getDisplayImagesWithCurpage:_curPage];
    //移掉划出屏幕外的图片 保存3个
    
    NSMutableArray *readyToRemove = [NSMutableArray array];
    for (MptTableHeadCell *view in self.onScreenCells) {
        BOOL onScreen = FALSE;
        for (NSNumber *number in self.onsScreenTags) { // 判断视图是不是需要显示
            if ([number intValue] == view.cellTag) {
                onScreen = TRUE;
                break;
            }
        }
        if (!onScreen) {
            [readyToRemove addObject:view];
        }
    }
    
    for (MptTableHeadCell *cell in readyToRemove) {
        [self queueContentCell:cell];
        
        [cell viewWillDisappear];
        [self.onScreenCells removeObject:cell];
        [cell removeFromSuperview];
        [cell viewDidDisappear];
        
    }
    //遍历图片数组
    
    for (int i = 0;i<self.onsScreenTags.count;i++) {
        
        BOOL OnScreen = TRUE;
        
        NSNumber *onNumber = [self.onsScreenTags objectAtIndex:i];
        int onTag = [onNumber intValue];
        

        //在屏幕范围内的创建添加s
        if (OnScreen) {
            BOOL HasOnScreen = FALSE;
            for (MptTableHeadCell *vi in self.onScreenCells) {
                if (onTag == vi.cellTag) {  //重新排列位置
                    HasOnScreen = TRUE;
                    CGRect frame = vi.frame;
                    frame.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame)*i, 0);
                    vi.frame = frame;
                    break;
                }
            }
            
            if (!HasOnScreen) {
                CGRect frame = CGRectMake(CGRectGetWidth(self.scrollView.frame)*i,0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
                MptTableHeadCell *cell = nil;
                if(_dataSource && [_dataSource respondsToSelector:@selector(cellViewForScrollView:frame:AtIndex:)]){
                    cell = [_dataSource cellViewForScrollView:self frame:frame AtIndex:onTag];
                }
                if (!cell)
                    cell = [[MptTableHeadCell alloc] initWithFrame:frame];
                
                cell.frame = frame;
                cell.cellTag = onTag;
                
                for(UIGestureRecognizer *gestures in cell.gestureRecognizers) {
                    [cell removeGestureRecognizer:gestures];
                }
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(handleTap:)];
                [cell addGestureRecognizer:singleTap];

                [cell viewWillAppear];
                [self.scrollView addSubview:cell];
                [cell viewDidAppear];
                
                [self.onScreenCells addObject:cell];
            }
        }
    }
    if (_total!=1) {
        [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame), 0)];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int x = scrollView.contentOffset.x;
    
    if(x >= (2*CGRectGetWidth(scrollView.frame))) {
        _curPage = [self validPageValue:_curPage+1];
        [self loadViews];
    }else if(x <= 0) {
        _curPage = [self validPageValue:_curPage-1];
        [self loadViews];
    }
    
    if (self.autoScroll) {
//        self.pageControl.currentPage = _curPage;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.autoScroll = NO;
//    [self.runloopTimer invalidate];
//    self.runloopTimer = nil;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSLog(@"page ==== %ld",_curPage);
    for (MptTableHeadCell *view in self.onScreenCells) {
        [view imageViewAnimation];
    }
    if (self.pageControl.currentPage != _curPage) {
        if ([_delegate respondsToSelector:@selector(tableHeadView:didScrollToIndex:)]) {
            [_delegate tableHeadView:self didScrollToIndex:_curPage];
        }
    }

    self.pageControl.currentPage = _curPage;
}// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"page ==== %ld",_curPage);
    if (self.pageControl.currentPage != _curPage) {
        if ([_delegate respondsToSelector:@selector(tableHeadView:didScrollToIndex:)]) {
            [_delegate tableHeadView:self didScrollToIndex:_curPage];
        }
    }
    self.pageControl.currentPage = _curPage;
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(scrollView:curIndex:)]) {
        [_dataSource scrollView:self curIndex:_curPage];
    }
    
//    self.runloopTimer = [NSTimer scheduledTimerWithTimeInterval:kAutoLoopIntervalS
//                                                         target:self
//                                                       selector:@selector(doAutoLoop)
//                                                       userInfo:nil
//                                                        repeats:YES];
    self.autoScroll = YES;
}

- (void)showArraw
{
    if (self.arrawAnimation) {
        return;
    }
    
    self.arrawAnimation = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backArraw.alpha = 1.0;
        self.nextArraw.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(fadeArraw) withObject:nil afterDelay:0.5];
    }];
}

- (void)fadeArraw
{
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.backArraw.alpha = 0.0;
        self.nextArraw.alpha = 0.0;
    } completion:^(BOOL finished) {
        weakSelf.arrawAnimation = NO;
    }];
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    [self showArraw];
    
    if ([_delegate respondsToSelector:@selector(tableHeadView:didSelectIndex:)]) {
        [_delegate tableHeadView:self didSelectIndex:_curPage];
    }
}

@end
