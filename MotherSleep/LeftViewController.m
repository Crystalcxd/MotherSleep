//
//  LeftViewController.m
//  Dictation
//
//  Created by Michael on 16/1/4.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "LeftViewController.h"
#import "SliderViewController.h"

#import "NoiseViewController.h"
#import "ShareViewController.h"

#import "Utility.h"
#import "WMUserDefault.h"

#import "TFLargerHitButton.h"

#import <MessageUI/MessageUI.h>

@interface LeftViewController ()<MFMailComposeViewControllerDelegate>

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = HexRGB(0xDC78FF);
    
    CGFloat width = [[SliderViewController sharedSliderController] LeftSContentOffset];
    
    CGFloat leftPadding = SCREENWIDTH - width;
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 109)];
    topView.backgroundColor = HexRGB(0xD04CFF);
    [self.view addSubview:topView];
    
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(39 + leftPadding, 38, 72, 39)];
    titleView.image = [UIImage imageNamed:NSLocalizedString(@"momsleep_white", nil)];
    [self.view addSubview:titleView];
        
    NSMutableArray *imageArr = [NSMutableArray arrayWithObjects:@"noise",@"share",@"advice", nil];
    NSMutableArray *selectImageArr = [NSMutableArray arrayWithObjects:@"whitenoise_touch" ,@"share_touch",@"suggest_touch",nil];
    NSMutableArray *titleArr = [NSMutableArray arrayWithObjects:NSLocalizedString(@"sleeping music", nil),NSLocalizedString(@"Share", nil),NSLocalizedString(@"YourAdvice", nil), nil];

    if (![Utility ifChinese]) {
        titleView.frame = CGRectMake(39 + leftPadding, 38, 105, 38);
    }
    
    for (int i = 0; i < imageArr.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(39, 159 + i * 93, 15, 15)];
        NSString *imgStr = imageArr[i];
        imageView.image = [UIImage imageNamed:imgStr];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 13, CGRectGetMinY(imageView.frame) - 8, 200, 28)];
        label.font = [UIFont fontWithName:@"DFPYuanW5" size:20];
        label.textColor = HexRGB(0xFFFFFF);
        label.text = titleArr[i];
        
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(leftPadding, CGRectGetMinY(imageView.frame) + 47, SCREENWIDTH * 0.618667, 3)];
        line.image = [UIImage imageNamed:@"line"];
        [self.view addSubview:line];
        
        UIButton *clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        clickBtn.frame = CGRectMake(39 + leftPadding, 123 + i * 93, 232, 80);
        [clickBtn setImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
        [clickBtn setImage:[UIImage imageNamed:selectImageArr[i]] forState:UIControlStateHighlighted];
        [clickBtn setTitle:titleArr[i] forState:UIControlStateNormal];
        [clickBtn setTitleColor:HexRGB(0xffffff) forState:UIControlStateNormal];
        [clickBtn setTitleColor:HexRGB(0xF0A6FF) forState:UIControlStateHighlighted];
        [clickBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 13, 0, 0)];
        [clickBtn.titleLabel setFont:[UIFont fontWithName:@"DFPYuanW5" size:18]];
        [clickBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        clickBtn.tag = TABLEVIEW_BEGIN_TAG + i;
        [clickBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:clickBtn];
    }
    
    NSString *str = NSLocalizedString(@"OtherApplications", nil);
    
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont fontWithName:@"DFPYuanW5" size:14]};
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(SCREENWIDTH, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    TFLargerHitButton *btn = [[TFLargerHitButton alloc] initWithFrame:CGRectMake(37 + leftPadding, SCREENHEIGHT - 42, size.width, 20)];
    [btn setTitle:NSLocalizedString(@"OtherApplications", nil) forState:UIControlStateNormal];
    [btn setTitleColor:HexRGB(0xF8D6FF) forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:@"DFPYuanW5" size:14]];
    [btn addTarget:self action:@selector(goOtherAppDownload) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    if (btn.tag == TABLEVIEW_BEGIN_TAG) {
        [self goNoiseView];
    }else if (btn.tag == TABLEVIEW_BEGIN_TAG + 1){
        [self goShareView];
    }else{
        [self sendMail];
    }
}

- (void)goNoiseView
{
    NoiseViewController *noiseVC = [[NoiseViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:noiseVC animated:YES completion:^{
        
    }];
}

- (void)goShareView
{
    ShareViewController *shareVC = [[ShareViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:shareVC animated:YES completion:^{
        
    }];
}

- (void)sendMail
{
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    [mailComposer setToRecipients:[NSArray arrayWithObject:@"207945016@qq.com"]];
    mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
    
    mailComposer.mailComposeDelegate = self; // Set the delegate
    
    [self presentViewController:mailComposer animated:YES completion:NULL];
}

- (void)goOtherAppDownload
{
    //跳转优惠券
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1004844450?mt=8"]];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *msg;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg = NSLocalizedString(@"Cancel the email", nil);
            break;
        case MFMailComposeResultSaved:
            msg = NSLocalizedString(@"Save the email successfully", nil);
            break;
        case MFMailComposeResultSent:
            msg = NSLocalizedString(@"Email has been sent", nil);
            break;
        case MFMailComposeResultFailed:
            msg = NSLocalizedString(@"Failed to send email", nil);
            break;
        default:
            break;
    }
    
    NSLog(@"%@",msg);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
