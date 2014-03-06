//
//  RosterCell.m
//  iPhoneXMPP
//
//  Created by FatKa Leung on 14-2-14.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import "RosterCell.h"

@implementation RosterCell

@synthesize userPhotoImageView,userNameLabel,messageContentLabel,messageCountBackgroundImageView,messageCountLabel,messageDateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        userPhotoImageView=[[UIImageView alloc] initWithFrame:CGRectMake(12.0, 6.0, 50.0, 50.0)];
        userPhotoImageView.backgroundColor=[UIColor clearColor];
        userPhotoImageView.layer.cornerRadius=8;
        userPhotoImageView.layer.masksToBounds=YES;
        [self.contentView addSubview:userPhotoImageView];
        
//        userPhotoImageButton=[UIButton buttonWithType:UIButtonTypeCustom];
//        userPhotoImageButton.frame=userPhotoImageView.frame;
//        [self.contentView addSubview:userPhotoImageButton];
        
        messageCountBackgroundImageView=[[UIImageView alloc] initWithFrame:CGRectMake(50.0, 1.0, 18.0, 18.0)];
        messageCountBackgroundImageView.image=[UIImage imageNamed:@"BadgeBackgroundImage.png"];
        [self.contentView addSubview:messageCountBackgroundImageView];
        
        messageCountLabel=[[UILabel alloc] initWithFrame:CGRectMake(50.0, 0.0, 18.0, 18.0)];
        messageCountLabel.backgroundColor=[UIColor clearColor];
        messageCountLabel.textAlignment=NSTextAlignmentCenter;
        messageCountLabel.textColor=[UIColor whiteColor];
        messageCountLabel.font=[UIFont systemFontOfSize:12.0];
        messageCountLabel.adjustsFontSizeToFitWidth=YES;
        [self.contentView addSubview:messageCountLabel];
        
        userNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userPhotoImageView.frame)+12.0, 10.0, 200.0, 20.0)];
        userNameLabel.backgroundColor=[UIColor clearColor];
        userNameLabel.textAlignment=NSTextAlignmentLeft;
        userNameLabel.textColor=[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:22.0/255.0 alpha:1.0];
        userNameLabel.font=[UIFont boldSystemFontOfSize:18.0];
        userNameLabel.adjustsFontSizeToFitWidth=YES;
        [self.contentView addSubview:userNameLabel];
        
        messageDateLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50-10, 10.0, 50.0, 20.0)];
        messageDateLabel.backgroundColor=[UIColor clearColor];
        messageDateLabel.textAlignment=NSTextAlignmentRight;
        messageDateLabel.textColor=[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0];
        messageDateLabel.font=[UIFont systemFontOfSize:12.0];
        messageDateLabel.adjustsFontSizeToFitWidth=YES;
        [self.contentView addSubview:messageDateLabel];
        
        messageContentLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userPhotoImageView.frame)+12.0, CGRectGetMaxY(userNameLabel.frame)+2, 220.0, 20.0)];
        messageContentLabel.backgroundColor=[UIColor clearColor];
        messageContentLabel.numberOfLines=1;
        messageContentLabel.textAlignment=NSTextAlignmentLeft;
        messageContentLabel.textColor=[UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0];
        messageContentLabel.font=[UIFont systemFontOfSize:14.0];
        //contentLabel.adjustsFontSizeToFitWidth=YES;
        messageContentLabel.numberOfLines=2;
        [self.contentView addSubview:messageContentLabel];
        
        UIImageView *separatorLineImageView=[[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userPhotoImageView.frame)+12.0, 61.0, SCREEN_WIDTH-(CGRectGetMaxX(userPhotoImageView.frame)+12.0), 1.0)];
        separatorLineImageView.backgroundColor=[UIColor clearColor];
        separatorLineImageView.image=[UIImage imageNamed:@"LineGray.png"];
        [self.contentView addSubview:separatorLineImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
