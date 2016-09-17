//
//  MusicCell.m
//  BabySleep
//
//  Created by Michael on 2016/8/3.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "MusicCell.h"

#import "Utility.h"

@interface MusicCell ()

@property (nonatomic , strong) UILabel *musicTitle;
@property (nonatomic , strong) UISlider *slider;

@end

@implementation MusicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.musicTitle = [[UILabel alloc] initWithFrame:CGRectMake(29, 0, 200, 82)];
        self.musicTitle.font = [UIFont fontWithName:@"DFPYuanW5" size:17];
        self.musicTitle.textColor = HexRGB(0xD0D0D0);
        [self addSubview:self.musicTitle];
        
        self.slider = [[UISlider alloc] initWithFrame:CGRectMake(120, 26, SCREENWIDTH - 120 - 30, 30)];
        [self.slider setMinimumTrackTintColor:HexRGB(0xD0D0D0)];
        [self.slider setMaximumTrackTintColor:HexRGB(0xD0D0D0)];
        [self.slider setThumbImage:[UIImage imageNamed:@"slide_enable"] forState:UIControlStateNormal];
        [self.slider setThumbImage:[UIImage imageNamed:@"slide_disable"] forState:UIControlStateDisabled];
        [self.slider addTarget:self action:@selector(slideValueChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.slider];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 81, SCREENWIDTH, 1)];
        line.backgroundColor = HexRGB(0xF8D6FF);
        [self addSubview:line];
    }
    
    return self;
}

- (void)configureWithName:(NSString *)name volum:(NSString *)volum selected:(BOOL)selected
{
    self.musicTitle.text = name;
    
    self.slider.value = volum.floatValue;
    
    if (selected) {
        self.slider.enabled = YES;
        self.musicTitle.textColor = HexRGB(0xD04CFF);
        [self.slider setMinimumTrackTintColor:HexRGB(0xD04CFF)];
    }else{
        self.slider.enabled = NO;
        self.musicTitle.textColor = HexRGB(0xD0D0D0);
        [self.slider setMinimumTrackTintColor:HexRGB(0xD0D0D0)];
    }
}

- (void)slideValueChange:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    
    self.VolumValueChange(slider.value);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
