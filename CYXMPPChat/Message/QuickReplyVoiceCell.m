//
//  QuickReplyVoiceCell.m
//  ExpertQAClient
//
//  Created by apple on 13-12-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "QuickReplyVoiceCell.h"

@implementation QuickReplyVoiceCell

@synthesize indexLabel;
@synthesize voiceView,image_e,playVoiceButton;
@synthesize timeStringLabel;
@synthesize describeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        indexLabel=[[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 20.0, 32.0)];
        indexLabel.backgroundColor=[UIColor clearColor];
        indexLabel.textAlignment=UITextAlignmentLeft;
        indexLabel.font=[UIFont systemFontOfSize:14.0];
        indexLabel.textColor=[UIColor blackColor];
        [self.contentView addSubview:indexLabel];
        
        voiceView=[[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(indexLabel.frame), 10.0, 65.0, 32.0)];
        voiceView.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:voiceView];
        
        UIImageView *voiceBgImg=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42.0, 30.0)];
        voiceBgImg.image=[UIImage imageNamed:@"messageBubbleGray"];
        [voiceBgImg setContentStretch:CGRectMake(0.5f, 0.65f, 0.2, 0)];
        CGRect frame = voiceBgImg.frame;
        frame.size.width=65.0;
        voiceBgImg.frame = frame;
        [voiceView addSubview:voiceBgImg];
        
        image_e=[[UIImageView alloc] initWithFrame:CGRectMake(13.0, 5.5, 15.0, 19.0)];
        image_e.image=[UIImage imageNamed:@"voice2_3.png"];
        image_e.animationImages=[NSArray arrayWithObjects:
                                 [UIImage imageNamed:@"voice2_1.png"],
                                 [UIImage imageNamed:@"voice2_2.png"],
                                 [UIImage imageNamed:@"voice2_3.png"],nil];
        image_e.animationDuration=1.0f;
        [voiceView addSubview:image_e];
        
        playVoiceButton=[UIButton buttonWithType:UIButtonTypeCustom];
        playVoiceButton.frame=CGRectMake(0, 0, 65.0, 19.0);
        [voiceView addSubview:playVoiceButton];
        
        timeStringLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(voiceView.frame)+5.0, 10.0, 100.0, 32.0)];
        timeStringLabel.backgroundColor=[UIColor clearColor];
        timeStringLabel.textAlignment=UITextAlignmentLeft;
        timeStringLabel.font=[UIFont systemFontOfSize:14.0];
        timeStringLabel.textColor=[UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1.0];
        [self.contentView addSubview:timeStringLabel];

        describeLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(voiceView.frame), CGRectGetMaxY(voiceView.frame), SCREEN_WIDTH-30.0, 20.0)];
        describeLabel.backgroundColor=[UIColor clearColor];
        describeLabel.textAlignment=UITextAlignmentLeft;
        describeLabel.font=[UIFont systemFontOfSize:14.0];
        describeLabel.textColor=[UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1.0];
        [self.contentView addSubview:describeLabel];
        
        UIImageView *endLineImg=[[UIImageView alloc] initWithFrame:CGRectMake(0, 64.0, SCREEN_WIDTH, 1.0)];
        endLineImg.backgroundColor=[UIColor clearColor];
        endLineImg.image=[UIImage imageNamed:@"line_gray.png"];
        [self.contentView addSubview:endLineImg];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
