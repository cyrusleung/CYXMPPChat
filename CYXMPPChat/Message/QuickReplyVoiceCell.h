//
//  QuickReplyVoiceCell.h
//  ExpertQAClient
//
//  Created by apple on 13-12-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickReplyVoiceCell : UITableViewCell

@property (nonatomic,retain) UILabel *indexLabel;
@property (nonatomic,retain) UIView *voiceView;
@property (nonatomic,retain) UIImageView *image_e;
@property (nonatomic,retain) UIButton *playVoiceButton;
@property (nonatomic,retain) UILabel *timeStringLabel;
@property (nonatomic,retain) UILabel *describeLabel;

@end
