//
//  QuickReplyTextCell.m
//  ExpertQAClient
//
//  Created by apple on 13-12-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "QuickReplyTextCell.h"

@implementation QuickReplyTextCell

@synthesize indexLabel;
@synthesize describeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        indexLabel=[[UILabel alloc] initWithFrame:CGRectMake(10.0, 6.5, 20.0, 32.0)];
        indexLabel.backgroundColor=[UIColor clearColor];
        indexLabel.textAlignment=UITextAlignmentLeft;
        indexLabel.font=[UIFont systemFontOfSize:14.0];
        indexLabel.textColor=[UIColor blackColor];
        [self.contentView addSubview:indexLabel];
        
        describeLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(indexLabel.frame), 6.5, SCREEN_WIDTH-30.0, 32.0)];
        describeLabel.backgroundColor=[UIColor clearColor];
        describeLabel.textAlignment=UITextAlignmentLeft;
        describeLabel.font=[UIFont systemFontOfSize:14.0];
        describeLabel.textColor=[UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1.0];
        [self.contentView addSubview:describeLabel];
        
        UIImageView *endLineImg=[[UIImageView alloc] initWithFrame:CGRectMake(0, 44.0, SCREEN_WIDTH, 1.0)];
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
