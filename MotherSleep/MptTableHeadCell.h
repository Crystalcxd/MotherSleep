//
//  MptTableHeadCell.h
//  TVGontrol
//
//  Created by Kyle on 13-5-7.
//  Copyright (c) 2013年 MIPT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MptTableHeadCell : UIImageView{
    
@private
    NSUInteger _cellTag;
    NSString *_identifier;
}

@property (nonatomic, assign) NSUInteger cellTag;
@property (nonatomic, strong) NSString *identifier;

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)identfier;

- (void)viewWillAppear;
- (void)viewDidAppear;

- (void)viewWillDisappear;
- (void)viewDidDisappear;


@end
