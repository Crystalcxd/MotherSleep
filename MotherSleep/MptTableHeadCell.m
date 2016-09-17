//
//  MptTableHeadCell.m
//  TVGontrol
//
//  Created by Kyle on 13-5-7.
//  Copyright (c) 2013年 MIPT. All rights reserved.
//

#import "MptTableHeadCell.h"

@implementation MptTableHeadCell
@synthesize identifier = _identifier;
@synthesize cellTag = _cellTag;

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)identfier
{
    self = [super initWithFrame:frame];
    if (self) {
        self.identifier = identfier;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)viewWillAppear{
    
}

- (void)viewDidAppear{
    
}

- (void)viewWillDisappear{
    
}

- (void)viewDidDisappear{
    
}

@end
