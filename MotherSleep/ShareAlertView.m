//
//  ShareAlertView.m
//  BabySleep
//
//  Created by Michael on 2016/7/17.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "ShareAlertView.h"

#import "TFLargerHitButton.h"

#import "Utility.h"

#import "WXApi.h"

@interface ShareAlertView ()

@property (nonatomic , strong) UIView *boardView;

@end

@implementation ShareAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.boardView = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH * 0.5 - 121, -234, 242, 234)];
        self.boardView.backgroundColor = HexRGB(0xF8D6FF);
        self.boardView.layer.borderWidth = 1.0;
        self.boardView.layer.borderColor = HexRGB(0xF5C5FF).CGColor;
        [self addSubview:self.boardView];
        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(26, 52, 195, 99)];
//        label.numberOfLines = 3;
//        label.text = @"现在分享给微信好友可以延长播放时间至60分钟喔！";
//        label.textColor = HexRGB(0xFA7FAD);
//        label.font = [UIFont fontWithName:@"DFPYuanW3" size:24];
//        [self.boardView addSubview:label];
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(18, 44, 211, 105)];
        textView.editable = NO;
        textView.backgroundColor = [UIColor clearColor];
        textView.showsVerticalScrollIndicator = NO;
        textView.showsHorizontalScrollIndicator = NO;
        textView.textColor = HexRGB(0xD04CFF);
        textView.scrollEnabled = NO;
        textView.font = [UIFont fontWithName:@"DFPYuanW3" size:24];
        textView.text = @"现在分享给微信好友可以拥有更多音乐喔！";
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 8;// 字体的行间距
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:textView.font,
                                     NSParagraphStyleAttributeName:paragraphStyle,
                                     NSForegroundColorAttributeName:textView.textColor
                                     };
        textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
        
        [self.boardView addSubview:textView];

        TFLargerHitButton *cancel = [TFLargerHitButton buttonWithType:UIButtonTypeCustom];
        cancel.frame = CGRectMake(206, 15, 18, 18);
        [cancel setImage:[UIImage imageNamed:@"cancel2"] forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(fadeView) forControlEvents:UIControlEventTouchUpInside];
        [self.boardView addSubview:cancel];
        
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.frame = CGRectMake(0, 164, 242, 70);
        [shareBtn setBackgroundColor:HexRGB(0xFFD1E2)];
        [shareBtn setBackgroundImage:[self createImageWithColor:HexRGB(0xDC78FF)] forState:UIControlStateNormal];
        [shareBtn setBackgroundImage:[self createImageWithColor:HexRGB(0xD04CFF)] forState:UIControlStateHighlighted];
        [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
        [shareBtn setTitleColor:HexRGB(0xFFFFFF) forState:UIControlStateNormal];
        [shareBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [shareBtn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        [self.boardView addSubview:shareBtn];
    }
    
    return self;
}

- (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)showView
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.boardView.frame;
        frame.origin.y = SCREENHEIGHT * 0.5 - 137;
        self.boardView.frame = frame;
    }];
}

- (void)fadeView
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.boardView.frame;
        frame.origin.y = SCREENHEIGHT;
        self.boardView.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)share
{
    WXMediaMessage *message = [self wxShareSiglMessageScene:[UIImage imageNamed:@"icon120.png"]];
    message.title = @"精选睡眠音乐，帮助妈咪好眠";
    message.description = @"精选睡眠音乐，帮助妈咪好眠";
    
    [self ShareWeixinLinkContent:message WXType:0];
}

#pragma mark - 微信分享
- (WXMediaMessage *)wxShareSiglMessageScene:(UIImage *)image
{
    WXMediaMessage *message = [WXMediaMessage message];
    
    WXWebpageObject *pageObject = [WXWebpageObject object];
    pageObject.webpageUrl = @"https://itunes.apple.com/cn/app/id1141414335?mt=8";
    
    message.mediaObject = pageObject;
    
    [message setThumbData:UIImageJPEGRepresentation(image,1)];
    
    return message;
}

- (void)ShareWeixinLinkContent:(WXMediaMessage *)message WXType:(NSInteger)scene {
    if ([WXApi isWXAppInstalled]) {
        SendMessageToWXReq *wxRequest = [[SendMessageToWXReq alloc] init];
        
        if ([message.mediaObject isKindOfClass:[WXWebpageObject class]]) {
            WXWebpageObject *webpageObject = message.mediaObject;
            if (webpageObject.webpageUrl.length == 0) {
                wxRequest.text = message.title;
                wxRequest.bText = YES;
            } else {
                wxRequest.message = message;
            }
        } else if ([message.mediaObject isKindOfClass:[WXImageObject class]]) {
            wxRequest.bText = NO;
            wxRequest.message = message;
        } else if ([message.mediaObject isKindOfClass:[WXVideoObject class]]) {
            wxRequest.bText = NO;
            wxRequest.message = message;
        }
        
        wxRequest.bText = NO;
        wxRequest.scene = (int)scene;
        
        [WXApi sendReq:wxRequest];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败" message:@"请使用其它分享途径。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
