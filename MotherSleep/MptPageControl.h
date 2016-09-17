//
//  MptPageControl.h
//  TVGontrol
//
//  Created by Kyle on 13-5-8.
//  Copyright (c) 2013年 MIPT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMMacro.h"

#define kDotGap 5.0f
#define kDotDiameter 5.0
#define kOrgX 10

@protocol MptPageControllDelegate;

@interface MptPageControl : UIView{

@private
    NSObject<MptPageControllDelegate> __weak_delegate *_delegate;
    NSUInteger _numberOfPages;
    NSUInteger _currentPage;
    float _dotWidth;
    float _dotSpace;
    UIImage *_imageNormal;
    UIImage *_imageCurrent;
    UIColor *_dotColorCurrentPage;
    UIColor *_dotColorOtherPage;
}

@property (nonatomic, weak_delegate) NSObject<MptPageControllDelegate> *delegate;
@property (nonatomic) NSUInteger numberOfPages;
@property (nonatomic) NSUInteger currentPage;

@property (nonatomic, readwrite, strong) UIImage* imageNormal;
@property (nonatomic, readwrite, strong) UIImage* imageCurrent;


// Customize these as well as the backgroundColor property.
@property (nonatomic, strong) UIColor *dotColorCurrentPage;
@property (nonatomic, strong) UIColor *dotColorOtherPage;
@property (nonatomic, assign) float dotWidth;
@property (nonatomic, assign) float dotSpace;

- (id)initWithFrame:(CGRect)frame Type:(NSInteger)type;

@end


@protocol MptPageControllDelegate <NSObject>

@optional
- (void)MptPageControlDidChangePage:(MptPageControl *)pageControl;

@end
