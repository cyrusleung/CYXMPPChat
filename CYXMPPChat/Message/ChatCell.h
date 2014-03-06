//
//  ChatCell.h
//  CYXMPPChat
//
//  Created by FatKa Leung on 14-2-16.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell

@property (nonatomic,retain)UIImageView *userIcon;
@property (nonatomic,retain)UIButton *userIconButton;
@property (nonatomic,retain)UIImageView *contentBg;
@property (nonatomic,retain)UIView *qaContentView;
@property (nonatomic,retain)UILabel *expertTime;

@end
