//
//  NoiseViewController.m
//  BabySleep
//
//  Created by medica_mac on 16/7/5.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "NoiseViewController.h"

#import "Utility.h"

#import "TFLargerHitButton.h"

@interface NoiseViewController ()

@end

@implementation NoiseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = HexRGB(0xF2EBFF);
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 70)];
    topView.backgroundColor = HexRGB(0xF2EBFF);
    topView.layer.borderColor = RGBA(220, 120, 255, 0.3).CGColor;
    topView.layer.borderWidth = 1.5;
    [self.view addSubview:topView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 29, SCREENWIDTH, 25)];
    title.textColor = HexRGB(0xDC78FF);
    title.textAlignment = NSTextAlignmentCenter;
    title.text = NSLocalizedString(@"sleeping music", nil);
    title.font = [UIFont fontWithName:@"DFPYuanW5" size:18];
    [self.view addSubview:title];
    
    TFLargerHitButton *backBtn = [[TFLargerHitButton alloc] initWithFrame:CGRectMake(22, 35, 14, 14)];
    [backBtn setImage:[UIImage imageNamed:@"cancel2"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backBtn];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(22, 106, SCREENWIDTH - 22 * 2, SCREENHEIGHT - 106)];
    textView.editable = NO;
    textView.backgroundColor = [UIColor clearColor];
    textView.showsVerticalScrollIndicator = NO;
    textView.showsHorizontalScrollIndicator = NO;
    textView.textColor = HexRGB(0x9E9E9E);
    textView.font = [UIFont fontWithName:@"DFPYuanW5" size:14];
    textView.text = NSLocalizedString(@"MusicIntro", nil);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 14;// 字体的行间距
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:textView.font,
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 NSForegroundColorAttributeName:textView.textColor
                                 };
    textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
    
    [self.view addSubview:textView];
}

- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
