//
//  VCardViewController.m
//  iPhoneXMPP
//
//  Created by FatKa Leung on 14-2-13.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import "VCardViewController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"

@interface VCardViewController ()

@end

@implementation VCardViewController

@synthesize userVCard;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

#pragma mark - my method
- (AppDelegate *)appDelegate
{
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    delegate.chatDelegate = self;
	return delegate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"个人资料"];
    
    CGFloat topOffsetY=64+15;
    CGFloat leftOffsetX=15;
    
    UIImageView *userPhotoImageView=[[UIImageView alloc] initWithFrame:CGRectMake(leftOffsetX, topOffsetY, 50.0, 50.0)];
    userPhotoImageView.backgroundColor=[UIColor clearColor];
    userPhotoImageView.layer.cornerRadius=8;
    userPhotoImageView.layer.masksToBounds=YES;
    NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:userVCard.jid];
    
    if (photoData != nil)
    {
        userPhotoImageView.image = [UIImage imageWithData:photoData];
    }
    else
    {
        userPhotoImageView.image = [UIImage imageNamed:@"DefaultPerson.png"];
    }
    
    [self.view addSubview:userPhotoImageView];
    
    UIButton *userPhotoImageButton=[UIButton buttonWithType:UIButtonTypeCustom];
    userPhotoImageButton.frame=userPhotoImageView.frame;
    [self.view addSubview:userPhotoImageButton];
    
    //加载vcard资料
    XMPPvCardCoreDataStorage *xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    XMPPvCardTempModule *xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    XMPPvCardTemp *xmppvCardTemp =[xmppvCardTempModule vCardTempForJID:userVCard.jid  shouldFetch:YES];
    
    UILabel *userNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userPhotoImageView.frame)+12.0, topOffsetY+2, 200.0, 20.0)];
    userNameLabel.backgroundColor=[UIColor clearColor];
    userNameLabel.textAlignment=NSTextAlignmentLeft;
    userNameLabel.textColor=[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:22.0/255.0 alpha:1.0];
    userNameLabel.font=[UIFont boldSystemFontOfSize:18.0];
    userNameLabel.adjustsFontSizeToFitWidth=YES;
    if(xmppvCardTemp.nickname)
    {
        userNameLabel.text=xmppvCardTemp.nickname;
    }
    else
    {
        userNameLabel.text=userVCard.jidStr;
    }
    [self.view addSubview:userNameLabel];
    
    UILabel *userSexLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userPhotoImageView.frame)+12.0, CGRectGetMaxY(userNameLabel.frame)+5, 200.0, 20.0)];
    userSexLabel.backgroundColor=[UIColor clearColor];
    userSexLabel.textAlignment=NSTextAlignmentLeft;
    userSexLabel.textColor=[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:22.0/255.0 alpha:1.0];
    userSexLabel.font=[UIFont boldSystemFontOfSize:18.0];
    
    if([xmppvCardTemp.sex compare:@"male"]==0)
    {
        userSexLabel.text=@"男";
    }
    else if([xmppvCardTemp.sex compare:@"female"]==0)
    {
        userSexLabel.text=@"女";
    }
    else
    {
        userSexLabel.text=@"未设置";
    }
    [self.view addSubview:userSexLabel];
    
    UIImageView *separatorLineImageView1=[[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(userPhotoImageView.frame)+15, SCREEN_WIDTH, 1.0)];
    separatorLineImageView1.backgroundColor=[UIColor clearColor];
    separatorLineImageView1.image=[UIImage imageNamed:@"LineGray.png"];
    [self.view addSubview:separatorLineImageView1];
    
    UILabel *userAccountTips=[[UILabel alloc] initWithFrame:CGRectMake(leftOffsetX, CGRectGetMaxY(separatorLineImageView1.frame)+10, 50.0, 20.0)];
    userAccountTips.backgroundColor=[UIColor clearColor];
    userAccountTips.textAlignment=NSTextAlignmentLeft;
    userAccountTips.textColor=[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:22.0/255.0 alpha:1.0];
    userAccountTips.font=[UIFont systemFontOfSize:16.0];
    userAccountTips.text=@"帐号";
    [self.view addSubview:userAccountTips];
    
    UILabel *userAccountLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userAccountTips.frame), CGRectGetMaxY(separatorLineImageView1.frame)+10, 250.0, 20.0)];
    userAccountLabel.backgroundColor=[UIColor clearColor];
    userAccountLabel.textAlignment=NSTextAlignmentLeft;
    userAccountLabel.textColor=[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:22.0/255.0 alpha:1.0];
    userAccountLabel.font=[UIFont systemFontOfSize:16.0];
    userAccountLabel.text=userVCard.jidStr;
    [self.view addSubview:userAccountLabel];
    
    UIImageView *separatorLineImageView2=[[UIImageView alloc] initWithFrame:CGRectMake(leftOffsetX, CGRectGetMaxY(userAccountTips.frame)+15, SCREEN_WIDTH, 1.0)];
    separatorLineImageView2.backgroundColor=[UIColor clearColor];
    separatorLineImageView2.image=[UIImage imageNamed:@"LineGray.png"];
    [self.view addSubview:separatorLineImageView2];
    
    UILabel *userBirthDayTips=[[UILabel alloc] initWithFrame:CGRectMake(leftOffsetX, CGRectGetMaxY(separatorLineImageView2.frame)+10, 50.0, 20.0)];
    userBirthDayTips.backgroundColor=[UIColor clearColor];
    userBirthDayTips.textAlignment=NSTextAlignmentLeft;
    userBirthDayTips.textColor=[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:22.0/255.0 alpha:1.0];
    userBirthDayTips.font=[UIFont systemFontOfSize:16.0];
    userBirthDayTips.text=@"生日";
    [self.view addSubview:userBirthDayTips];
    
    UILabel *userRealNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userAccountTips.frame), CGRectGetMaxY(separatorLineImageView2.frame)+10, 250.0, 20.0)];
    userRealNameLabel.backgroundColor=[UIColor clearColor];
    userRealNameLabel.textAlignment=NSTextAlignmentLeft;
    userRealNameLabel.textColor=[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:22.0/255.0 alpha:1.0];
    userRealNameLabel.font=[UIFont systemFontOfSize:16.0];
    userRealNameLabel.text=xmppvCardTemp.birthDay ;
    [self.view addSubview:userRealNameLabel];
    
    UIImageView *separatorLineImageView3=[[UIImageView alloc] initWithFrame:CGRectMake(leftOffsetX, CGRectGetMaxY(userBirthDayTips.frame)+15, SCREEN_WIDTH, 1.0)];
    separatorLineImageView3.backgroundColor=[UIColor clearColor];
    separatorLineImageView3.image=[UIImage imageNamed:@"LineGray.png"];
    [self.view addSubview:separatorLineImageView3];
    
    UILabel *userUrlTips=[[UILabel alloc] initWithFrame:CGRectMake(leftOffsetX, CGRectGetMaxY(separatorLineImageView3.frame)+10, 50.0, 20.0)];
    userUrlTips.backgroundColor=[UIColor clearColor];
    userUrlTips.textAlignment=NSTextAlignmentLeft;
    userUrlTips.textColor=[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:22.0/255.0 alpha:1.0];
    userUrlTips.font=[UIFont systemFontOfSize:16.0];
    userUrlTips.text=@"网页";
    [self.view addSubview:userUrlTips];
    
    UILabel *userUrlLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userAccountTips.frame), CGRectGetMaxY(separatorLineImageView3.frame)+10, 250.0, 20.0)];
    userUrlLabel.backgroundColor=[UIColor clearColor];
    userUrlLabel.textAlignment=NSTextAlignmentLeft;
    userUrlLabel.textColor=[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:22.0/255.0 alpha:1.0];
    userUrlLabel.font=[UIFont systemFontOfSize:16.0];
    userUrlLabel.text=xmppvCardTemp.url ;
    [self.view addSubview:userUrlLabel];
    
    UIImageView *separatorLineImageView4=[[UIImageView alloc] initWithFrame:CGRectMake(leftOffsetX, CGRectGetMaxY(userUrlTips.frame)+15, SCREEN_WIDTH, 1.0)];
    separatorLineImageView4.backgroundColor=[UIColor clearColor];
    separatorLineImageView4.image=[UIImage imageNamed:@"LineGray.png"];
    [self.view addSubview:separatorLineImageView4];
    
    UILabel *userDescTips=[[UILabel alloc] initWithFrame:CGRectMake(leftOffsetX, CGRectGetMaxY(separatorLineImageView4.frame)+10, 50.0, 20.0)];
    userDescTips.backgroundColor=[UIColor clearColor];
    userDescTips.textAlignment=NSTextAlignmentLeft;
    userDescTips.textColor=[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:22.0/255.0 alpha:1.0];
    userDescTips.font=[UIFont systemFontOfSize:16.0];
    userDescTips.text=@"说明";
    [self.view addSubview:userDescTips];
    
    UILabel *userDescLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userAccountTips.frame), CGRectGetMaxY(separatorLineImageView4.frame)+10, 250.0, 20.0)];
    userDescLabel.backgroundColor=[UIColor clearColor];
    userDescLabel.textAlignment=NSTextAlignmentLeft;
    userDescLabel.textColor=[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:22.0/255.0 alpha:1.0];
    userDescLabel.font=[UIFont systemFontOfSize:16.0];
    userDescLabel.text=xmppvCardTemp.description ;
    [self.view addSubview:userDescLabel];
    
    UIImageView *separatorLineImageView5=[[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(userDescTips.frame)+15, SCREEN_WIDTH, 1.0)];
    separatorLineImageView5.backgroundColor=[UIColor clearColor];
    separatorLineImageView5.image=[UIImage imageNamed:@"LineGray.png"];
    [self.view addSubview:separatorLineImageView5];
    
}

//- (NSString *)stringFromDate:(NSDate *)date{
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    
//    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息 +0000。
//    
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
//    
//    NSString *destDateString = [dateFormatter stringFromDate:date];
//    
//    
//    return destDateString;
//    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
