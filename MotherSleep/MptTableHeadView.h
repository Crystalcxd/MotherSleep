//
//  MptTableHeadView.h
//  TVGontrol
//
//  Created by Kyle on 13-5-7.
//  Copyright (c) 2013年 MIPT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMMacro.h"

typedef enum : NSUInteger {
    MptTableHeadViewUser = 1,
    MptTableHeadViewOther,
} MptTableHeadViewType;

typedef enum : NSUInteger {
    ScrollTypeBack = 0,
    ScrollTypeForce,
} ScrollType;

@class MptTableHeadCell;
@class MptPageControl;

@protocol HeadViewDataSource;
@protocol HeadViewDelegate;

@interface MptTableHeadView : UIView {
  @private

    id<HeadViewDataSource> __weak_delegate _dataSource;
    id<HeadViewDelegate> __weak_delegate _delegate;
    UIScrollView *_scrollView;
    MptPageControl *_pageControl;
    NSMutableArray *_onScreenCells;
    NSMutableDictionary *_saveCells;
    NSUInteger _total;
    NSUInteger _curPage;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSUInteger curPage;
@property (nonatomic, assign) BOOL autoScroll;

@property (nonatomic, strong) UIImageView *backArraw;
@property (nonatomic, strong) UIImageView *nextArraw;

@property (nonatomic, strong) MptPageControl *pageControl;

@property (nonatomic, weak_delegate) id<HeadViewDataSource> dataSource;
@property (nonatomic, weak_delegate) id<HeadViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame Type:(NSInteger)type;
- (MptTableHeadCell *)dequeueCellWithIdentifier:(NSString *)identifier;
// 刷新轮播图数据
- (void)reloadData;
- (void)stopAnimation;

- (void)scrollWithType:(ScrollType)type;

@end

@protocol HeadViewDataSource <NSObject>

@required
- (NSUInteger)numberOfItemFor:(MptTableHeadView *)scrollView;
- (MptTableHeadCell *)cellViewForScrollView:(MptTableHeadView *)scrollView frame:(CGRect)frame AtIndex:(NSUInteger)index;

@optional
- (void)scrollView:(MptTableHeadView *)scrollView curIndex:(NSUInteger)index;

@end

@protocol HeadViewDelegate <NSObject>
@optional

- (void)tableHeadView:(MptTableHeadView *)headView didSelectIndex:(NSUInteger)index;

- (void)tableHeadView:(MptTableHeadView *)headView didScrollToIndex:(NSUInteger)index;

@end
