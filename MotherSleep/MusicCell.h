//
//  MusicCell.h
//  BabySleep
//
//  Created by Michael on 2016/8/3.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^volumValueChange)(CGFloat);

@interface MusicCell : UITableViewCell

@property (nonatomic , copy) volumValueChange VolumValueChange;

- (void)configureWithName:(NSString *)name volum:(NSString *)volum selected:(BOOL)selected;

@end
