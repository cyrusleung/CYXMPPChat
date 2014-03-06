//
//  QuickReplyViewController.m
//  ExpertQAClient
//
//  Created by apple on 13-12-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "QuickReplyViewController.h"
#import "QuickReplyVoiceCell.h"
#import "QuickReplyTextCell.h"
#import "NSData+Base64.h"

@interface QuickReplyViewController ()
{
    UITableView *replyTable;
    NSMutableArray *replyDataArray;
    
    //输入栏
    UIView *insertReplyView;
    UIImageView *inputFieldBg;
    UITextField *replyTF;
    UIButton *voiceButton;
    UIButton *pressButton;
    BOOL isVoiceAvailable;
    
    UIView *voiceRemarkView;
    UITextView *voiceRemarkTV;
    
    int tfType;//文本框类型：1：replyTF,2:voiceRemarkTF
    
    BOOL playingVoice;
}

@property (nonatomic,retain)NSData *wavData;
@property (nonatomic,retain)NSString *wavDataString;

@end

@implementation QuickReplyViewController

@synthesize QRDelegate;

@synthesize recorderVC;
@synthesize player;
@synthesize originWav;

@synthesize wavData,wavDataString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark 录单标题输入框

-(void)initWihtVoiceRemarkView
{
    voiceRemarkView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    voiceRemarkView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    voiceRemarkView.alpha=0.0;
    [self.view addSubview:voiceRemarkView];
    
    UIView *contentBgView=[[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-270.0)/2.0, 30.0, 270.0, 160.0)];
    contentBgView.backgroundColor=[UIColor whiteColor];
    contentBgView.layer.cornerRadius=5.0;
    [voiceRemarkView addSubview:contentBgView];
    
    UILabel *title_temp=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, 270.0, 20.0)];
    title_temp.backgroundColor=[UIColor clearColor];
    title_temp.text=@"添加语音标题";
    title_temp.font=[UIFont boldSystemFontOfSize:16.0];
    title_temp.textAlignment=UITextAlignmentCenter;
    title_temp.textColor=[UIColor blackColor];
    [contentBgView addSubview:title_temp];
    
    voiceRemarkTV=[[UITextView alloc] initWithFrame:CGRectMake(5.0, CGRectGetMaxY(title_temp.frame), 260, 80)];
    voiceRemarkTV.backgroundColor=[UIColor clearColor];
    voiceRemarkTV.delegate=self;
    voiceRemarkTV.font=[UIFont systemFontOfSize:14.0];
    voiceRemarkTV.textColor=[UIColor blackColor];
    voiceRemarkTV.returnKeyType=UIReturnKeyDone;
    [contentBgView addSubview:voiceRemarkTV];
    
    UIView *line_h=[[UIView alloc] initWithFrame:CGRectMake(0, 115.0, 270.0, 1.0)];
    line_h.backgroundColor=[UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1.0];
    [contentBgView addSubview:line_h];

    
    UIView *line_v=[[UIView alloc] initWithFrame:CGRectMake(269.0/2.0, 115.0, 1.0, 45.0)];
    line_v.backgroundColor=[UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1.0];
    [contentBgView addSubview:line_v];

    
    UIButton *cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame=CGRectMake(0, 116.0, 269.0/2.0, 44.0);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    cancelButton.titleLabel.font=[UIFont systemFontOfSize:16.0];
    cancelButton.tag=0;
    [cancelButton addTarget:self action:@selector(voiceRemarkAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentBgView addSubview: cancelButton];
    
    UIButton *comfirmButton=[UIButton buttonWithType:UIButtonTypeCustom];
    comfirmButton.frame=CGRectMake(CGRectGetMaxX(cancelButton.frame)+1.0, 116.0, 269.0/2.0, 44.0);
    [comfirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [comfirmButton setTitleColor:[UIColor colorWithRed:0/255.0 green:120.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    comfirmButton.titleLabel.font=[UIFont systemFontOfSize:16.0];
    comfirmButton.tag=1;
    [comfirmButton addTarget:self action:@selector(voiceRemarkAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentBgView addSubview: comfirmButton];
    
}

-(void)voiceRemarkAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 0:
        {
            [self hideVoiceRemarkView];
            break;
        }
        case 1:
        {
            if (!self.player) {
                self.player = [[AVAudioPlayer alloc]init];
            }
            self.player = [self.player initWithData:self.wavData error:nil];
            NSString *describeString=[NSString stringWithFormat:@"%.0f||（%@）",self.player.duration,voiceRemarkTV.text];
            
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:@"2",@"type",self.wavDataString,@"content",describeString,@"describeString", nil];
            NSMutableArray *arr_temp=[[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"ExpertQuickReply"]];
            [arr_temp addObject:dict];
            [replyDataArray removeAllObjects];
            [replyDataArray addObjectsFromArray:arr_temp];
            [[NSUserDefaults standardUserDefaults] setObject:arr_temp forKey:@"ExpertQuickReply"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [replyTable reloadData];
            [self hideVoiceRemarkView];
            break;
        }
        default:
            break;
    }
}

-(void)showVoiceRemarkView
{
    if (!voiceRemarkView) {
        [self initWihtVoiceRemarkView];
    }
    [self.view bringSubviewToFront:voiceRemarkView];
    
    [UIView animateWithDuration:0.3f animations:^{
        voiceRemarkView.alpha=1.0;
    } completion:^(BOOL finished){
        [voiceRemarkTV becomeFirstResponder];
    }];
}

-(void)hideVoiceRemarkView
{
    [voiceRemarkTV resignFirstResponder];
    [UIView animateWithDuration:0.3f animations:^{
        voiceRemarkView.alpha=0.0;
    } completion:^(BOOL finished){
        
    }];
}

#pragma mark toolBarButtonAction
-(void)showHideTextField
{
    if(isVoiceAvailable)
    {
        [voiceButton setImage:[UIImage imageNamed:@"qa_voice.png"] forState:UIControlStateNormal];
        [pressButton setHidden:YES];
        [inputFieldBg setHidden:NO];
        [replyTF setHidden:NO];
        [replyTF becomeFirstResponder];
        isVoiceAvailable=NO;
    }
    else
    {
        [voiceButton setImage:[UIImage imageNamed:@"qa_s.png"] forState:UIControlStateNormal];
        [pressButton setHidden:NO];
        [inputFieldBg setHidden:YES];
        [replyTF setHidden:YES];
        [replyTF resignFirstResponder];
        isVoiceAvailable=YES;
    }
}

#pragma mark - 长按录音
- (void)buttonTouchBegin:(UIButton *)sender
{
    [self beginAudio:sender];
    NSLog(@"start voice y");
}

- (void)buttonTouchEnd:(UIButton *)sender
{
    [recorderVC endRecord];
    [self endAudio:sender];
    NSLog(@"end voice y");
}

- (void)beginAudio:(id)sender {
    //设置文件名
    self.originWav = [VoiceRecorderBaseVC getCurrentTimeString];
    //开始录音
    [recorderVC beginRecordByFileName:self.originWav];
    
}

- (void)endAudio:(id)sender {
    [VoiceConverter wavToAmr:[VoiceRecorderBaseVC getPathByFileName:originWav ofType:@"wav"] amrSavePath:[VoiceRecorderBaseVC getPathByFileName:self.originWav ofType:@"amr"]];
    
}

#pragma mark insertReplyView
-(void)initWithInsertReplyView
{
    insertReplyView=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-46.0, SCREEN_WIDTH, 46.0)];
    if ([[UIDevice currentDevice].systemVersion floatValue]>=7.0) {
        insertReplyView.frame=CGRectMake(0, self.view.frame.size.height-66.0, SCREEN_WIDTH, 46.0);
    }
    insertReplyView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:insertReplyView];
    
    UIImageView *bgImg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qa_bg.png"]];
    bgImg.frame=CGRectMake(0, 0, SCREEN_WIDTH, 46.0);
    [insertReplyView addSubview:bgImg];

    
    voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceButton.frame = CGRectMake(7.0f, 8.0f, 30.0f, 30.0f);
    [voiceButton setImage:[UIImage imageNamed:@"qa_voice.png"] forState:UIControlStateNormal];
    [voiceButton addTarget:self action:@selector(showHideTextField) forControlEvents:UIControlEventTouchUpInside];
    [insertReplyView addSubview:voiceButton];
    
    pressButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pressButton.frame = CGRectMake(44.0f, 8.0f, SCREEN_WIDTH-53.0, 32.0f);
    [pressButton setTitle:@"按住说话" forState:UIControlStateNormal];
    [pressButton setTitle:@"松开结束" forState:UIControlStateHighlighted];
    [pressButton setTitle:@"松开结束" forState:UIControlStateSelected];
    [pressButton setTitleColor:[UIColor colorWithRed:88.0/255.0 green:88.0/255.0 blue:88.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    pressButton.titleLabel.font=[UIFont systemFontOfSize:15.0];
    [pressButton setBackgroundImage:[UIImage imageNamed:@"qa_sbg_nw.png"] forState:UIControlStateNormal];
    [pressButton setBackgroundImage:[UIImage imageNamed:@"qa_sbg_hl_nw.png"] forState:UIControlStateHighlighted];
    [pressButton setBackgroundImage:[UIImage imageNamed:@"qa_sbg_hl_nw.png"] forState:UIControlStateSelected];
    [pressButton addTarget:self action:@selector(buttonTouchBegin:) forControlEvents:UIControlEventTouchDown];
    [pressButton addTarget:self action:@selector(buttonTouchEnd:) forControlEvents:UIControlEventTouchUpInside];
    [pressButton addTarget:self action:@selector(buttonTouchEnd:) forControlEvents:UIControlEventTouchUpOutside];
    pressButton.hidden=YES;
    [insertReplyView addSubview:pressButton];
    
    inputFieldBg = [[UIImageView alloc] initWithFrame:CGRectMake(43.0,
                                                                              0.0f,
                                                                              SCREEN_WIDTH-49.0,
                                                                              46.0)];
    inputFieldBg.image = [[UIImage imageNamed:@"qa_ebg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 12.0f, 18.0f, 18.0f)];
    inputFieldBg.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [insertReplyView addSubview:inputFieldBg];
    
    
    replyTF = [[UITextField alloc] initWithFrame:CGRectMake(45.0f, 14.0f, SCREEN_WIDTH-53.0, 20.0)];
    replyTF.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    replyTF.placeholder=@"添加快捷回复";
    replyTF.backgroundColor = [UIColor clearColor];
    replyTF.userInteractionEnabled = YES;
    replyTF.delegate=self;
    replyTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    replyTF.font = [UIFont systemFontOfSize:16.0f];
    replyTF.textColor = [UIColor blackColor];
    replyTF.returnKeyType = UIReturnKeyDone;
    [insertReplyView addSubview:replyTF];    
}

#pragma mark NavigationBar
- (void)goBack:(id)sender
{
    if (playingVoice) {
        [player stop];
    }
    [replyTF resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)initNavigationBar
{
    //去掉导航
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    UIView *bgView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    [bgView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:bgView];

    
    UIImage *navImage=[UIImage imageNamed:@"nav-bg.png"];
    UIImageView *navImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    [navImageView setImage:navImage];
    [self.view addSubview:navImageView];

    
    UILabel *nav_titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(44, 0, SCREEN_WIDTH-88.0, 44)];
    [nav_titleLabel setBackgroundColor:[UIColor clearColor]];
    [nav_titleLabel setText:[NSString stringWithFormat:@"%@",@"快捷回复"]];
    [nav_titleLabel setTextColor:[UIColor colorWithRed:120.0/255.0 green:58.0/255.0 blue:16.0/255.0 alpha:1.0]];
    [nav_titleLabel setShadowColor:[UIColor colorWithRed:246.0/255.0 green:204.0/255.0 blue:141.0/255.0 alpha:1]];
    [nav_titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [nav_titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    nav_titleLabel.adjustsFontSizeToFitWidth=YES;
    [nav_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:nav_titleLabel];

    
    UIButton *leftButton=[UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame=CGRectMake(0, 0, 44, 44);
    [leftButton setImage:[UIImage imageNamed:@"nav-back.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"nav-btn-bg"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
    
    //手势操作
    UISwipeGestureRecognizer *ges=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goBack:)];
    [ges setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:ges];

    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    [self initNavigationBar];
    
    tfType=0;
    
    replyDataArray=[[NSMutableArray alloc] init];
    
    NSArray *array=[[NSUserDefaults standardUserDefaults] objectForKey:@"ExpertQuickReply"]?[[NSUserDefaults standardUserDefaults] objectForKey:@"ExpertQuickReply"]:nil;
    if (array) {
        [replyDataArray addObjectsFromArray:array];
    }else{
        NSArray *arr_temp=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"type",@"您好，专家忙碌中，会尽快解答您的问题！",@"content",@"",@"describeString", nil], nil];
        [replyDataArray addObjectsFromArray:arr_temp];
        
        [[NSUserDefaults standardUserDefaults] setObject:arr_temp forKey:@"ExpertQuickReply"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    replyTable=[[UITableView alloc] initWithFrame:CGRectMake(0, 44.0, SCREEN_WIDTH, SCREEN_HEIGHT-64.0-46.0) style:UITableViewStylePlain];
    replyTable.backgroundColor=[UIColor clearColor];
    replyTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    replyTable.delegate=self;
    replyTable.dataSource=self;
    [self.view addSubview:replyTable];
    
    [replyTable reloadData];
    
    [self initWithInsertReplyView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    //初始化录音vc
    recorderVC = [[ChatVoiceRecorderVC alloc]init];
    recorderVC.vrbDelegate = self;
    
    //初始化播放器
    self.player = [[AVAudioPlayer alloc]init];
}

#pragma mark UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [replyDataArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict=[replyDataArray objectAtIndex:indexPath.row];
    if ([[dict objectForKey:@"type"] intValue]==0) {
        return 45.0;
    }else{
        return 65.0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict=[replyDataArray objectAtIndex:indexPath.row];
    if ([[dict objectForKey:@"type"] intValue]==0) {
        static NSString *contentCellIndentifier=@"QuickReplyTextCell";
        QuickReplyTextCell *cell=[tableView dequeueReusableCellWithIdentifier:contentCellIndentifier];
        if (!cell) {
            cell=[[QuickReplyTextCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:contentCellIndentifier];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.accessoryType=UITableViewCellAccessoryNone;
            cell.backgroundColor=[UIColor clearColor];
            
        }
        
        cell.indexLabel.text=[NSString stringWithFormat:@"%d.",indexPath.row+1];
        CGSize indexSize=[cell.indexLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(300, 2000) lineBreakMode:NSLineBreakByCharWrapping];
        cell.indexLabel.frame=CGRectMake(cell.indexLabel.frame.origin.x, cell.indexLabel.frame.origin.y, indexSize.width, cell.indexLabel.frame.size.height);
        cell.describeLabel.text=[dict objectForKey:@"content"];
        cell.describeLabel.frame=CGRectMake(CGRectGetMaxX(cell.indexLabel.frame)+5.0, cell.describeLabel.frame.origin.y, SCREEN_WIDTH-CGRectGetMaxX(cell.indexLabel.frame)-5.0, cell.describeLabel.frame.size.height);
        
        return cell;
    }else{
        static NSString *contentCellIndentifier=@"QuickReplyVoiceCell";
        QuickReplyVoiceCell *cell=[tableView dequeueReusableCellWithIdentifier:contentCellIndentifier];
        if (!cell) {
            cell=[[QuickReplyVoiceCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:contentCellIndentifier];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.accessoryType=UITableViewCellAccessoryNone;
            cell.backgroundColor=[UIColor clearColor];
        }
        cell.indexLabel.text=[NSString stringWithFormat:@"%d.",indexPath.row+1];
        CGSize indexSize=[cell.indexLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(300, 2000) lineBreakMode:NSLineBreakByCharWrapping];
        cell.indexLabel.frame=CGRectMake(cell.indexLabel.frame.origin.x, cell.indexLabel.frame.origin.y, indexSize.width, cell.indexLabel.frame.size.height);
        cell.voiceView.frame=CGRectMake(CGRectGetMaxX(cell.indexLabel.frame)+5.0, cell.voiceView.frame.origin.y, cell.voiceView.frame.size.width, cell.voiceView.frame.size.height);
        cell.playVoiceButton.tag=indexPath.row;
        [cell.playVoiceButton addTarget:self action:@selector(playVoiceAction:) forControlEvents:UIControlEventTouchUpInside];
        NSArray *arr_temp=[[dict objectForKey:@"describeString"] componentsSeparatedByString:@"||"];
        
        cell.timeStringLabel.text=[NSString stringWithFormat:@"%@''",[arr_temp objectAtIndex:0]];
        cell.timeStringLabel.frame=CGRectMake(CGRectGetMaxX(cell.voiceView.frame)+5.0, cell.timeStringLabel.frame.origin.y, cell.timeStringLabel.frame.size.width, cell.timeStringLabel.frame.size.height);
        cell.describeLabel.text=[arr_temp objectAtIndex:1];
        return cell;
    }
 
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==replyTable) {
        if ([self.QRDelegate respondsToSelector:@selector(finishedSelectQuickReplyToSend:)]) {
            NSDictionary *dict=[replyDataArray objectAtIndex:indexPath.row];
            NSString *replyString=[NSString stringWithFormat:@"%@",[dict objectForKey:@"content"]];
            [self.QRDelegate performSelector:@selector(finishedSelectQuickReplyToSend:) withObject:replyString];
            [self goBack:nil];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==replyTable) {
        if (editingStyle==UITableViewCellEditingStyleDelete) {
            NSMutableArray *array=[[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"ExpertQuickReply"]];
            [array removeObjectAtIndex:indexPath.row];
            [replyDataArray removeAllObjects];
            [replyDataArray addObjectsFromArray:array];
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"ExpertQuickReply"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [replyTable reloadData];
        }
    }
}

#pragma mark 播放录音
-(NSString *)readyCacheFile:(NSString *)fileName withData:(NSData *)data
{
    BOOL success;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSString *writableDBPath=[documentsDirectory stringByAppendingPathComponent:fileName];
    success=[fileManager fileExistsAtPath:writableDBPath];
    if(!success)
    {
        success=[fileManager createFileAtPath:writableDBPath contents:data attributes:nil];
        if(!success)
        {
            NSLog(@"%@",[error localizedDescription]);
        }
        else
        {
        }
    }
    return writableDBPath;
}


- (NSString *) getAmrFileName
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyyMMddhhmmssSSS"];
    return [NSString stringWithFormat:@"%@.amr",[formatter stringFromDate:[NSDate date]]];
}


-(void)playVoiceAction:(UIButton *)sender
{
    playingVoice=YES;
    
    NSDictionary *dict=[replyDataArray objectAtIndex:sender.tag];
    NSString *replyString=[NSString stringWithFormat:@"%@",[dict objectForKey:@"content"]];
    
    NSData *amr=[NSData dataWithBase64EncodedString:[replyString substringFromIndex:5]];
    NSString *amrFileName=[self getAmrFileName];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyyMMddhhmmssSSS"];
    NSString *wavFileName=[NSString stringWithFormat:@"%@",[formatter stringFromDate:[NSDate date]]];
    
    //转格式
    [VoiceConverter amrToWav:[self readyCacheFile:amrFileName withData:amr] wavSavePath:[VoiceRecorderBaseVC getPathByFileName:wavFileName ofType:@"wav"]];
    self.player = [self.player initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:wavFileName ofType:@"wav"]] error:nil];
    [self.player play];
    QuickReplyVoiceCell *cell_temp=(QuickReplyVoiceCell*)[replyTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    cell_temp.image_e.animationRepeatCount=self.player.duration;
    [cell_temp.image_e startAnimating];
    
    [self performSelector:@selector(playVoiceEnd) withObject:nil afterDelay:self.player.duration];
}

-(void)playVoiceEnd
{
    playingVoice=NO;
}

#pragma mark UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField==replyTF) {
        tfType=1;
    }else{
        tfType=2;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField==replyTF) {
        [UIView animateWithDuration:0.28f animations:^{
            insertReplyView.frame=CGRectMake(insertReplyView.frame.origin.x, self.view.frame.size.height-insertReplyView.frame.size.height, insertReplyView.frame.size.width, insertReplyView.frame.size.height);
        } completion:^(BOOL finished){
            
        }];
    }
    tfType=0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==replyTF) {
        [replyTF resignFirstResponder];
        NSString *replyString=replyTF.text;
        if ([replyString compare:@""]!=0) {
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"type",replyString,@"content",@"",@"describeString", nil];
            NSMutableArray *arr_temp=[[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"ExpertQuickReply"]];
            [arr_temp addObject:dict];
            
            replyTF.text=@"";
            [replyDataArray removeAllObjects];
            [replyDataArray addObjectsFromArray:arr_temp];
            [[NSUserDefaults standardUserDefaults] setObject:arr_temp forKey:@"ExpertQuickReply"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [replyTable reloadData];
        }
    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView==voiceRemarkTV) {
        tfType=2;
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView==voiceRemarkTV) {
        if ([text isEqualToString:@"\n"]) {
            
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            button.tag=1;
            [self voiceRemarkAction:button];
            return NO;
        }
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (tfType==1) {
        NSDictionary*info=[notification userInfo];
        CGSize kbSize=[[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
        [UIView animateWithDuration:0.28f animations:^{
            insertReplyView.frame=CGRectMake(insertReplyView.frame.origin.x, self.view.frame.size.height-kbSize.height-insertReplyView.frame.size.height, insertReplyView.frame.size.width, insertReplyView.frame.size.height);
        } completion:^(BOOL finished){
            
        }];
    }
}

#pragma mark - VoiceRecorderBaseVC Delegate Methods
//录音完成回调，返回文件路径和文件名
- (void)VoiceRecorderBaseVCRecordFinish:(NSString *)_filePath fileName:(NSString*)_fileName{
    NSLog(@"record finished %@",_fileName);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[[paths objectAtIndex:0]stringByAppendingPathComponent:@"Voice"] stringByAppendingPathComponent:[[_fileName stringByAppendingString:@".amr"] stringByReplacingOccurrencesOfString:@".wav" withString:@""] ];
    NSLog(@"path:%@",path);
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    if ([fileManager fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSString *base64 = [data base64EncodedString];
        
        NSMutableString *soundString = [[NSMutableString alloc]initWithString:@"[[2]]"];
        [soundString appendString:base64];
        
        self.wavData=data;
        self.wavDataString=soundString;
        
        [self performSelectorOnMainThread:@selector(insertVoiceTitle) withObject:nil waitUntilDone:YES];

    }
}

-(void)insertVoiceTitle
{
    [self showVoiceRemarkView];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
