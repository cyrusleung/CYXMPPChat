//
//  RosterCell.h
//  iPhoneXMPP
//
//  Created by FatKa Leung on 14-2-14.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RosterCell : UITableViewCell

@property (nonatomic,retain)UIImageView *userPhotoImageView;
//@property (nonatomic,retain)UIButton *userPhotoImageButton;
@property (nonatomic,retain)UILabel *userNameLabel;
@property (nonatomic,retain)UILabel *messageContentLabel;
@property (nonatomic,retain)UILabel *messageDateLabel;
@property (nonatomic,retain)UIImageView *messageCountBackgroundImageView;
@property (nonatomic,retain)UILabel *messageCountLabel;

@end
