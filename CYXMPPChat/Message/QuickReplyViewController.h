//
//  QuickReplyViewController.h
//  ExpertQAClient
//
//  Created by apple on 13-12-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatVoiceRecorderVC.h"
#import "VoiceConverter.h"

@protocol QuickReplyDelegate <NSObject>

@optional
-(void)finishedSelectQuickReplyToSend:(NSString *)sendText;

@end

@interface QuickReplyViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate,UITextViewDelegate,VoiceRecorderBaseVCDelegate>

@property (nonatomic,assign) id<QuickReplyDelegate> QRDelegate;

@property (retain, nonatomic) ChatVoiceRecorderVC  *recorderVC;
@property (retain, nonatomic) AVAudioPlayer *player;
@property (copy, nonatomic) NSString *originWav;

@end
