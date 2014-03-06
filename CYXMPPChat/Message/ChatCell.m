//
//  ChatCell.m
//  CYXMPPChat
//
//  Created by FatKa Leung on 14-2-16.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import "ChatCell.h"
#import "MessageInputView.h"


@implementation ChatCell

@synthesize userIcon,userIconButton;
@synthesize contentBg;
@synthesize qaContentView;
@synthesize expertTime;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        expertTime=[[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-120.0)/2.0, 5.0, 120, 20.0)];
        expertTime.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        expertTime.font=[UIFont systemFontOfSize:11.0];
        expertTime.textAlignment=NSTextAlignmentCenter;
        expertTime.textColor=[UIColor blackColor];
        expertTime.layer.cornerRadius=5.0;
        expertTime.adjustsFontSizeToFitWidth=YES;
        [self.contentView addSubview:expertTime];
        
        userIcon=[[UIImageView alloc] initWithFrame:CGRectMake(7.0, CGRectGetMaxY(expertTime.frame)+1.0, 40, 40)];
        userIcon.layer.masksToBounds=YES;
        userIcon.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:userIcon];
        
        userIconButton=[UIButton buttonWithType:UIButtonTypeCustom];
        userIconButton.backgroundColor=[UIColor clearColor];
        userIconButton.frame=userIcon.frame;
        userIconButton.userInteractionEnabled=NO;
        [self.contentView addSubview:userIconButton];
        
        contentBg=[[UIImageView alloc] initWithFrame:CGRectMake(50.0, CGRectGetMinY(userIcon.frame)+10.0, 42.0, 30.0)];
        [self.contentView addSubview:contentBg];
        
        qaContentView=[[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(contentBg.frame)+10.0, CGRectGetMinY(contentBg.frame)+5.0, 27.0, 20.0)];
        qaContentView.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:qaContentView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canResignFirstResponder
{
    return YES;
}

@end
