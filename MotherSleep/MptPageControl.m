//
//  MptPageControl.m
//  TVGontrol
//
//  Created by Kyle on 13-5-8.
//  Copyright (c) 2013年 MIPT. All rights reserved.
//

#import "MptPageControl.h"

#import "Utility.h"

@interface MptPageControl()

@end


@implementation MptPageControl
@synthesize delegate = _delegate;
@synthesize numberOfPages = _numberOfPages;
@synthesize currentPage = _currentPage;
@synthesize imageNormal = _imageNormal;
@synthesize imageCurrent = _imageCurrent;
@synthesize dotColorCurrentPage = _dotColorCurrentPage;
@synthesize dotColorOtherPage = _dotColorOtherPage;
@synthesize dotWidth = _dotWidth;
@synthesize dotSpace = _dotSpace;

- (id)initWithFrame:(CGRect)frame Type:(NSInteger)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        if (type == 1) {
            self.dotColorCurrentPage = kNavBGColor;
        }else
            self.dotColorCurrentPage = [UIColor whiteColor];
        self.dotColorOtherPage = [UIColor colorWithWhite:211/255.0 alpha:0.5];
		self.dotWidth = kDotDiameter;
		self.dotSpace = kDotGap;
    }
    return self;
}

#pragma mark
#pragma mark property
/** Override setImageNormal */
- (void) setImageNormal:(UIImage*)image {
    _imageNormal = image;
    
	// update dot views
	[self setNeedsDisplay];
}

/** Override setImageCurrent */
- (void) setImageCurrent:(UIImage*)image
{
    _imageCurrent = image;
    // update dot views
	[self setNeedsDisplay];
}

- (NSUInteger)currentPage
{
    return _currentPage;
}

- (void)setCurrentPage:(NSUInteger)page
{
    _currentPage = MIN(MAX(0, page), _numberOfPages-1);
    [self setNeedsDisplay];
}

- (NSUInteger)numberOfPages
{
    return _numberOfPages;
}

- (void)setNumberOfPages:(NSUInteger)pages
{
    _numberOfPages = MAX(0, pages);
    _currentPage = MIN(MAX(0, _currentPage), _numberOfPages-1);
    [self setNeedsDisplay];
}

-(void)layoutSubviews {
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
	// Flip the context because UIKit coordinate system is upside down to Quartz coordinate system
    //	CGContextTranslateCTM(context, 0.0, rect.size.height);
    //    CGContextScaleCTM(context, 1.0, -1.0);
	
	CGRect currentBounds = self.bounds;
	CGFloat dotsWidth = self.numberOfPages*self.dotWidth + MAX(0, self.numberOfPages-1)*self.dotSpace;
	CGFloat x = CGRectGetWidth(currentBounds)*0.5- dotsWidth*0.5;
	CGFloat y = CGRectGetMidY(currentBounds)-self.dotWidth/2;
	for (int i=0; i<_numberOfPages; i++)
	{
		CGRect circleRect = CGRectMake(x, y, self.dotWidth, self.dotWidth);
		if (i == _currentPage)
		{
			if(nil != _imageCurrent) {
				//CGContextDrawTiledImage(context, circleRect, mImageCurrent.CGImage);
				[_imageCurrent drawInRect:circleRect];
			} else {
				CGContextSetFillColorWithColor(context, self.dotColorCurrentPage.CGColor);
				CGContextFillEllipseInRect(context, circleRect);
			}
			
		}
		else
		{
			if(nil != _imageNormal) {
				//CGContextDrawTiledImage(context, circleRect, mImageNormal.CGImage);
				[_imageNormal drawInRect:circleRect];
			} else {
				CGContextSetFillColorWithColor(context, self.dotColorOtherPage.CGColor);
				CGContextFillEllipseInRect(context, circleRect);
			}
		}
		
		x += self.dotWidth + self.dotSpace;
	}	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.delegate) return;
	
    CGPoint touchPoint = [[[event touchesForView:self] anyObject] locationInView:self];
	
    CGFloat dotSpanX = self.numberOfPages*(self.dotWidth + self.dotSpace);
    CGFloat dotSpanY = self.dotWidth + self.dotSpace;
	
    CGRect currentBounds = self.bounds;
    CGFloat x = touchPoint.x + dotSpanX/2 - CGRectGetMidX(currentBounds);
    CGFloat y = touchPoint.y + dotSpanY/2 - CGRectGetMidY(currentBounds);
	
    if ((x<0) || (x>dotSpanX) || (y<0) || (y>dotSpanY)) return;
	
    
	self.currentPage = floor(x/(self.dotWidth + self.dotSpace));
	
    if ([self.delegate respondsToSelector:@selector(MptPageControlDidChangePage:)])
    {
        [self.delegate performSelector:@selector(MptPageControlDidChangePage:) withObject:self afterDelay:.1];
    }
}

@end
