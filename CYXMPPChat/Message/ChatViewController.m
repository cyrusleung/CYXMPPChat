//
//  ChatViewController.m
//  CYXMPPChat
//
//  Created by FatKa Leung on 14-2-16.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import "ChatViewController.h"
#import "MessageInputView.h"

#import "XMPPvCardTemp.h"
#import "Photo.h"
#import "FileHelpers.h"
#import "ImageCacher.h"
#import "UIImageView+Addition.h"
#import "ChatClass.h"
#import "NSData+Base64.h"
#import "MyNetHelper.h"
#import "MyWebViewController.h"
#import "MyLongPressGestureRecognizer.h"

@interface ChatViewController ()
{
    NSDateFormatter *dateFormatter;
    BOOL refreshForDismiss;
    
    
    NSMutableArray *messageArray;//所有信息数组
    NSMutableArray *messageImageArray;//仅含图片的信息数组
    NSMutableArray *QAContentArray;//对话内容视图数组（表情+文字）
    NSMutableArray *cellHeightArray;//cell的高度
    
    int loadMessageType;//消息读取形式
    BOOL playingVoice;//播放音频
    
    BOOL loadingMoreData;//正在读取更多数据
    BOOL loadTotalData;//已读取全部数据
    UILabel *loadMoreDataTipsView;//提示上拉
    
    int longPressCellIndex;//长按事件的cell
    
    UIImagePickerController *imgPicker;
    
    UILabel *sendResultLabel;//发送失败
    
    UILabel *receiveMsgLabel;//信息提示
    
    FGalleryViewController *msgImgGallery;//本地消息图片
}
@property (nonatomic,retain)NSDate *preQATime;//上一次对话时间

@property (nonatomic, strong) NSString *toJIDString;
@property (nonatomic, strong) XMPPJID *toJID;
@property (copy, nonatomic) NSString *originWav;

@end

@implementation ChatViewController

@synthesize xmppUserObject;

@synthesize recorderVC;
@synthesize messageTextField;
@synthesize player;

@synthesize preQATime;

@synthesize toJIDString;
@synthesize toJID;
@synthesize originWav;

@synthesize targetPhoto;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark receiveMsgLabel
-(void)initWithReceiveMsgLabel
{
    receiveMsgLabel=[[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100.0)/2.0, 44.0, 100.0, 20.0)];
    receiveMsgLabel.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    receiveMsgLabel.layer.cornerRadius=5.0;
    receiveMsgLabel.text=@"您收到一条新信息";
    receiveMsgLabel.textColor=[UIColor whiteColor];
    receiveMsgLabel.textAlignment=UITextAlignmentCenter;
    receiveMsgLabel.font=[UIFont systemFontOfSize:14.0];
    receiveMsgLabel.alpha=0.0;
    receiveMsgLabel.numberOfLines=0;
    receiveMsgLabel.hidden=YES;
    [self.view addSubview:receiveMsgLabel];
}

-(void)showReceiveMsgLabel:(NSString *)resultStr{
    if (!receiveMsgLabel) {
        [self initWithReceiveMsgLabel];
    }
    
    CGSize size=[resultStr sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(300, 2000) lineBreakMode:NSLineBreakByWordWrapping];
    receiveMsgLabel.text=resultStr;
    receiveMsgLabel.frame=CGRectMake((SCREEN_WIDTH-size.width-10.0)/2.0, 44.0, size.width+10.0, size.height+10.0);
    
    receiveMsgLabel.hidden=NO;
    [self.view bringSubviewToFront:receiveMsgLabel];
    [UIView animateWithDuration:0.3f animations:^{
        receiveMsgLabel.alpha=1.0;
    } completion:^(BOOL finished){
        [self performSelector:@selector(dismissReceiveMsgLabel) withObject:nil afterDelay:2.0];
    }];
    
    
}
-(void)dismissReceiveMsgLabel{
    [UIView animateWithDuration:0.3f animations:^{
        receiveMsgLabel.alpha=0.0;
    } completion:^(BOOL finished){
        receiveMsgLabel.hidden=YES;
    }];
}

#pragma marl sendResultLabel
-(void)initWithSendResultLabel
{
    sendResultLabel=[[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100.0)/2.0, (self.view.frame.size.height-20.0)/2.0, 100.0, 20.0)];
    sendResultLabel.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    sendResultLabel.layer.cornerRadius=5.0;
    sendResultLabel.text=@"发送失败";
    sendResultLabel.textColor=[UIColor whiteColor];
    sendResultLabel.textAlignment=UITextAlignmentCenter;
    sendResultLabel.font=[UIFont systemFontOfSize:14.0];
    sendResultLabel.alpha=0.0;
    sendResultLabel.hidden=YES;
    [self.view addSubview:sendResultLabel];
}

-(void)showSendResultLabel:(NSString *)resultStr{
    if (!sendResultLabel) {
        [self initWithSendResultLabel];
    }
    
    CGSize size=[resultStr sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(300, 2000) lineBreakMode:NSLineBreakByWordWrapping];
    sendResultLabel.text=resultStr;
    sendResultLabel.frame=CGRectMake((SCREEN_WIDTH-size.width-10.0)/2.0, (self.view.frame.size.height-size.height-10.0)/2.0, size.width+10.0, size.height+10.0);
    
    sendResultLabel.hidden=NO;
    [self.view bringSubviewToFront:sendResultLabel];
    [UIView animateWithDuration:0.3f animations:^{
        sendResultLabel.alpha=1.0;
    } completion:^(BOOL finished){
        [self performSelector:@selector(dismissSendResultLabel) withObject:nil afterDelay:2.0];
    }];
    
    
}
-(void)dismissSendResultLabel{
    [UIView animateWithDuration:0.3f animations:^{
        sendResultLabel.alpha=0.0;
    } completion:^(BOOL finished){
        sendResultLabel.hidden=YES;
    }];
}

#pragma mark chatDelegate
- (AppDelegate *)appDelegate
{
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.chatDelegate = self;
	return delegate;
}

-(void)getNewMessage:(AppDelegate *)appD Message:(XMPPMessage *)message
{
    loadMessageType=kWCMessageTypeLoadLimit;
    [self getMessageData];
    [self.tableView reloadData];
    if ([messageArray count]>0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)showMsgTips:(AppDelegate *)appD Message:(NSString *)message
{
    [self showReceiveMsgLabel:message];
}

- (void)getMessageData{
    
    NSArray *strs=[[NSString stringWithFormat:@"%@",self.xmppUserObject.jidStr] componentsSeparatedByString:@"@"];
    
    if (loadMessageType==kWCMessageTypeLoadAll) {
        [messageArray removeAllObjects];
        [messageImageArray removeAllObjects];
        [QAContentArray removeAllObjects];
        [cellHeightArray removeAllObjects];
        
        [self fetchedResultsController];
//        [msgRecords addObjectsFromArray:[WCMessageObject fetchMessageListWithUserRecently:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID] ExpertId:strs[0] byPage:1 limit:20 Desc:@"desc"]];
//        
//        for (int i=0; i<[msgRecords count]; i++) {
//            [self setQAContentArrayAction:[msgRecords objectAtIndex:i]];
//        }
    }else if (loadMessageType==kWCMessageTypeLoadLimit){
//        [msgRecords addObject:[[WCMessageObject fetchMessageListWithUserRecently:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID] ExpertId:strs[0] byPage:1 limit:1 Desc:@"desc"] objectAtIndex:0]];
//        [self setQAContentArrayAction:[msgRecords lastObject]];
        [self fetchedResultsController:0 limit:1 asc:NO];
        
        [msgImgGallery reloadGallery];
    }
    if ([messageArray count]<20) {
        loadTotalData=YES;
    }
    [self.tableView reloadData];
    
    if ([[UIDevice currentDevice].systemVersion floatValue]>=7.0) {
        [self performSelector:@selector(scrollTableToBottom) withObject:nil afterDelay:0];
    }else{
        if ([messageArray count]>0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController != nil)
	{
        fetchedResultsController = nil;
    }
    
    
    
//        [HUD show:YES];
    
//    NSString *myJidUserDef = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCYXMPPMyJid"];
//        
//		NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_message];
//		
//		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
//		                                          inManagedObjectContext:moc];
//		
//		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:YES];
//		
//		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
//        
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(messageFrom==%@ and messageTo==%@) or (messageFrom==%@ and messageTo==%@ )",xmppUserObject.jidStr, myJidUserDef,myJidUserDef,xmppUserObject.jidStr];
//    
//        
//		
//		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//		[fetchRequest setEntity:entity];
//		[fetchRequest setSortDescriptors:sortDescriptors];
//        
//        [fetchRequest setPredicate:predicate];
//		[fetchRequest setFetchBatchSize:10];
//        
//        
//	
//		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
//		                                                               managedObjectContext:moc
//		                                                                 sectionNameKeyPath:nil
//		                                                                          cacheName:nil];
		
    fetchedResultsController=[self fetchedResultsController:0 limit:20 asc:YES];
    [fetchedResultsController setDelegate:self];
        
//        [HUD hide:YES];
    
    
	
	return fetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController:(int)offset limit:(int)limit asc:(BOOL)asc
{
    NSString *myJidUserDef = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCYXMPPMyJid"];
    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_message];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:asc];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(messageFrom==%@ and messageTo==%@) or (messageFrom==%@ and messageTo==%@ )",xmppUserObject.jidStr, myJidUserDef,myJidUserDef,xmppUserObject.jidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate:predicate];
//    [fetchRequest setFetchBatchSize:10];
    [fetchRequest setFetchLimit:limit];
    [fetchRequest setFetchOffset:offset];
	
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                   managedObjectContext:moc
                                                                     sectionNameKeyPath:nil
                                                                              cacheName:nil];
    
    NSError *error = nil;
    
    NSMutableArray *mutableFetchResult = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
    NSMutableArray *entries = mutableFetchResult;
    
    
    NSMutableArray *messageList=[[NSMutableArray alloc]init];
    for (XMPPMessageCoreDataStorageObject *entry in entries) {
        MessageObject *messageObj=[[MessageObject alloc] init];
        messageObj.messageFrom=entry.messageFrom;
        messageObj.messageTo=entry.messageTo;
        messageObj.messageContent=entry.messageContent;
        messageObj.messageDate=entry.messageDate;
        messageObj.messageType=entry.messageType;
        
        [messageList addObject:messageObj];
        [self setQAContentArrayAction:entry];
    }
    
    [messageArray addObjectsFromArray:messageList];
    
    return controller;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
//    NSString *myJidUserDef = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCYXMPPMyJid"];
//    
//    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_message];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
//                                              inManagedObjectContext:moc];
//    
//    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:YES];
//    
//    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(messageFrom==%@ and messageTo==%@) or (messageFrom==%@ and messageTo==%@ )",xmppUserObject.jidStr, myJidUserDef,myJidUserDef,xmppUserObject.jidStr];
//    
//    
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    [fetchRequest setEntity:entity];
//    [fetchRequest setSortDescriptors:sortDescriptors];
//    
//    [fetchRequest setPredicate:predicate];
//    [fetchRequest setFetchBatchSize:10];
//    
//    
//	
//    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
//                                                                   managedObjectContext:moc
//                                                                     sectionNameKeyPath:nil
//                                                                              cacheName:nil];
//    [fetchedResultsController setDelegate:self];
//    
//    [HUD hide:YES];
//    
//    NSError *error = nil;
//    
//    NSMutableArray *mutableFetchResult = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
//    if (mutableFetchResult == nil) {
//        NSLog(@"Error: %@,%@",error,[error userInfo]);
//    }
//    NSMutableArray *entries = mutableFetchResult;
//    
//    NSLog(@"The count of entry:%i",[entries count]);
//    
//    [QAContentArray removeAllObjects];
//    for (XMPPMessageCoreDataStorageObject *entry in entries) {
//        
//        
//        [self setQAContentArrayAction:entry];
//        NSLog(@"from:%@---to:%@---content:%@----date:%@",entry.messageFrom,entry.messageTo,entry.messageContent,entry.messageDate);
//    }
//    
//    NSLog(@"%@",QAContentArray);
    
    [self fetchedResultsController:1 limit:20 asc:YES];
    
    [self.tableView reloadData];
//	[[self tableView] reloadData];
}

-(void)scrollTableToBottom
{
    if ([messageArray count]>0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)setQAContentArrayAction:(XMPPMessageCoreDataStorageObject *)messageObject
{
    
    //NSData *data = [messageObject.messageContent dataUsingEncoding:NSUTF8StringEncoding];
    //NSString *questionString = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    NSString *questionString=messageObject.messageContent;
    NSArray *strs=[[NSString stringWithFormat:@"%@",self.xmppUserObject.jidStr] componentsSeparatedByString:@"@"];
    UIView *tempView;
    int messageType=messageObject.messageType?[messageObject.messageType intValue]:0;
    if (messageType==2) {
        //录音
        tempView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,20.0, 20.0)];
        tempView.backgroundColor=[UIColor clearColor];
        
        NSString *content=messageObject.messageContent;
        NSData *amr=[NSData dataWithBase64EncodedString:[content substringFromIndex:5]];
        NSString *amrFileName=[self getAmrFileName];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"yyyyMMddhhmmssSSS"];
        NSString *wavFileName=[NSString stringWithFormat:@"%@",[formatter stringFromDate:[NSDate date]]];
        //转格式
        [VoiceConverter amrToWav:[self readyCacheFile:amrFileName withData:amr] wavSavePath:[VoiceRecorderBaseVC getPathByFileName:wavFileName ofType:@"wav"]];
        if (!self.player) {
            self.player = [[AVAudioPlayer alloc]init];
        }
        self.player = [self.player initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:wavFileName ofType:@"wav"]] error:nil];
        NSString *timeString=[NSString stringWithFormat:@"%.0f''",self.player.duration];
        CGSize timeStringSize=[timeString sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByCharWrapping];
        
        UILabel *timeLabel_temp=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, timeStringSize.width, 20.0)];
        timeLabel_temp.backgroundColor=[UIColor clearColor];
        timeLabel_temp.text=timeString;
        timeLabel_temp.font=[UIFont systemFontOfSize:14.0];
        timeLabel_temp.textColor=[UIColor blackColor];
        [tempView addSubview:timeLabel_temp];
        
        UIImageView *image_e=[[UIImageView alloc] initWithFrame:CGRectMake(2.5, 0.5, 15.0, 19.0)];
        if([messageObject.messageFrom compare:strs[0]]==0){
            image_e.frame=CGRectMake(2.5, 0.5, 15.0, 19.0);
            timeLabel_temp.frame=CGRectMake(CGRectGetMaxX(image_e.frame)+2.5, 0, timeStringSize.width+10, 20.0);
            
            image_e.image=[UIImage imageNamed:@"voice2_3.png"];
            image_e.animationImages=[NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"voice2_1.png"],
                                     [UIImage imageNamed:@"voice2_2.png"],
                                     [UIImage imageNamed:@"voice2_3.png"],nil];
        }else{
            //个人
            timeLabel_temp.frame=CGRectMake(12.5, 0, timeStringSize.width, 20.0);
            image_e.frame=CGRectMake(CGRectGetMaxX(timeLabel_temp.frame)+2.5, 0.5, 15.0, 19.0);
            
            image_e.image=[UIImage imageNamed:@"voice1_3.png"];
            image_e.animationImages=[NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"voice1_1.png"],
                                     [UIImage imageNamed:@"voice1_2.png"],
                                     [UIImage imageNamed:@"voice1_3.png"],nil];
        }
        image_e.animationDuration=1.0f;
        [tempView addSubview:image_e];
        
        tempView.frame=CGRectMake(0, 0,20.0+timeStringSize.width+12.5, 20.0);
        
        UIButton *playVoiceButton=[UIButton buttonWithType:UIButtonTypeCustom];
        playVoiceButton.frame=CGRectMake(0, 0, tempView.frame.size.width, 20.0);
        [playVoiceButton addTarget:self action:@selector(playVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
        [tempView addSubview:playVoiceButton];
        [QAContentArray addObject:tempView];
    }else if(messageType==1) {
        NSString *sendImageUrl=[messageObject.messageContent substringFromIndex:5];
        tempView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,120.0, 160.0)];
        tempView.backgroundColor=[UIColor clearColor];
        
        UIImageView *image_e=[[UIImageView alloc] initWithFrame:tempView.frame];
        [tempView addSubview:image_e];
        if ([sendImageUrl compare:@"mall-cbg3.png"]==0) {
            image_e.image=[UIImage imageNamed:sendImageUrl];
            
            UIActivityIndicatorView *indicatorView_temp=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicatorView_temp.frame=CGRectMake((120.0-37.0)/2.0,(160.0-37.0)/2.0, 37.0, 37.0);
            [tempView addSubview:indicatorView_temp];
            [indicatorView_temp startAnimating];
        }else{
            if (hasCachedImage([NSURL URLWithString:sendImageUrl])) {
                image_e.image=[UIImage imageWithContentsOfFile:pathForURL([NSURL URLWithString:sendImageUrl])];
            }else
            {
                image_e.image=[UIImage imageNamed:@"mall-cbg3.png"];
                NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[NSURL URLWithString:sendImageUrl],@"url",image_e,@"imageView",nil];
                [NSThread detachNewThreadSelector:@selector(cacheImageOriginal:) toTarget:[ImageCacher defaultCacher] withObject:dic];
            }
        }
//        [msgArray addObject:sendImageUrl];
        [image_e addDetailShow_chat];
//        [image_e release];
        
        UIButton *playImageButton=[UIButton buttonWithType:UIButtonTypeCustom];
        playImageButton.frame=image_e.frame;
//        playImageButton.tag=[msgArray count]-1;
        [playImageButton addTarget:self action:@selector(playImageButton:) forControlEvents:UIControlEventTouchUpInside];
        [tempView addSubview:playImageButton];
        
        [QAContentArray addObject:tempView];
        
    }
    else{
        tempView=[ChatClass assembleMessageAtIndex:[ChatClass parserMessage_new:questionString] SuperClass:self];
        [QAContentArray addObject:tempView];
    }
    
    float rowHeight=0;
    if (!self.preQATime) {
        self.preQATime=messageObject.messageDate;
    }
    double timeApart=[messageObject.messageDate timeIntervalSinceDate:self.preQATime];
    self.preQATime=messageObject.messageDate;
    if (timeApart<60&&timeApart!=0) {
        rowHeight=0.0;
    }else{
        rowHeight=20.0;
    }
    if (tempView.frame.size.height<30) {
        rowHeight=24.0+30.0+rowHeight;
    }else{
        rowHeight=tempView.frame.size.height+30.0+rowHeight;
    }
    [cellHeightArray addObject:[NSString stringWithFormat:@"%f",rowHeight]];
}

#pragma mark 查看更多纪录
//更多纪录（10条）
-(void)getMoreMessageData
{
    if (loadTotalData) {
        return;
    }
    if (loadingMoreData) {
        return;
    }
    loadingMoreData=YES;
//    NSArray *strs=[[NSString stringWithFormat:@"%@",self.xmppUserObject.jidStr] componentsSeparatedByString:@"@"];
//    NSArray *moreArray=[WCMessageObject fetchMessageListWithUserRecently:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID] ExpertId:strs[0] FromIndex:[msgRecords count] limit:10 Desc:@"desc"];
//    
//    for (int i=[moreArray count]-1; i>=0; i--) {
//        [msgRecords insertObject:[moreArray objectAtIndex:i] atIndex:0];
//    }
//    
//    if ([moreArray count]<10) {
//        loadTotalData=YES;
//    }
//    
//    [QAContentArray removeAllObjects];
//    [cellHeightArray removeAllObjects];
//    for (int i=0; i<[msgRecords count]; i++) {
//        [self setQAContentArrayAction:[msgRecords objectAtIndex:i]];
//    }
//    [self performSelector:@selector(tableViewScrollToIndex:) withObject:[NSString stringWithFormat:@"%d",[moreArray count]-1] afterDelay:0.3];
    loadingMoreData=NO;
}

-(void)tableViewScrollToIndex:(NSString *)indexStr
{
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[indexStr intValue] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void)initWithLoadMoreDataTipsView
{
    loadMoreDataTipsView=[[UILabel alloc] initWithFrame:CGRectMake(0, 44.0, SCREEN_WIDTH, 12.0)];
    loadMoreDataTipsView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    loadMoreDataTipsView.text=@"上拉读取更多记聊天记录...";
    loadMoreDataTipsView.textColor=[UIColor whiteColor];
    loadMoreDataTipsView.textAlignment=UITextAlignmentCenter;
    loadMoreDataTipsView.font=[UIFont systemFontOfSize:10.0];
    //loadMoreDataTipsView.hidden=YES;
    [self.view addSubview:loadMoreDataTipsView];
}

-(void)showLoadMoreDataTipsView:(BOOL)isShow
{
    if (!loadMoreDataTipsView) {
        [self initWithLoadMoreDataTipsView];
    }
    [self.view bringSubviewToFront:loadMoreDataTipsView];
    if (loadTotalData) {
        loadMoreDataTipsView.hidden=YES;
    }else{
        loadMoreDataTipsView.hidden=!isShow;
    }
    
}

#pragma mark RTLabelDelegate
- (void)clickOnTextAction:(NSString*)type
{
    [self.inputView.textView resignFirstResponder];
    
    NSRange httpRange_temp=[type rangeOfString:@"http://"];
    NSRange httpsRange_temp=[type rangeOfString:@"https://"];
    NSRange ftpRange_temp=[type rangeOfString:@"ftp://"];
    NSRange wwwRange_temp=[type rangeOfString:@"www."];
    if (httpRange_temp.length>0||ftpRange_temp.length>0||httpsRange_temp.length>0||wwwRange_temp.length>0) {
        refreshForDismiss=YES;
        MyWebViewController *controller = [[MyWebViewController alloc] initWithNibName:@"MyWebViewController" bundle:nil];
        controller.urlStr = type;
        [self.navigationController pushViewController:controller animated:YES];
//        [controller release];
    }
}

#pragma mark navBar
- (void)goBack:(id)sender
{
    //ios7.0下
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
        self.tableView.delegate=nil;
    }
    
    //end
    
    if (playingVoice) {
        [player stop];
    }
    
//    [ExpertClientSingleton sharedInstance].currentClientAccount=@"";
//    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.chatDelegate = nil;
//    if([self.beforeLogin compare:@"ExpertList"]==0)
//    {
//        for (int i=0; i<[self.navigationController.viewControllers count]; i++) {
//            if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[ExpertMainViewController class]]) {
//                ExpertMainViewController *controller=[self.navigationController.viewControllers objectAtIndex:i];
//                [self.navigationController popToViewController:controller animated:YES];
//                break;
//            }
//        }
//    }else{
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}

-(void)viewDidAppear:(BOOL)animated
{
    if (messageArray&&QAContentArray&&cellHeightArray&&refreshForDismiss) {
        refreshForDismiss=NO;
        loadTotalData=NO;
        loadMessageType=kWCMessageTypeLoadAll;
        self.preQATime=nil;
        [self getMessageData];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    //refreshForDismiss=YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    XMPPvCardCoreDataStorage *xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    XMPPvCardTempModule *xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    XMPPvCardTemp *xmppvCardTemp =[xmppvCardTempModule vCardTempForJID:xmppUserObject.jid  shouldFetch:YES];
    
    dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    messageArray=[[NSMutableArray alloc] init];
    QAContentArray=[[NSMutableArray alloc] init];
    cellHeightArray=[[NSMutableArray alloc] init];
    messageImageArray=[[NSMutableArray alloc] init];
    msgImgGallery=[[FGalleryViewController alloc] initWithPhotoSource:self];
    
    loadMessageType=kWCMessageTypeLoadAll;
    
    [self getMessageData];
    
    //初始化录音vc
    recorderVC = [[ChatVoiceRecorderVC alloc]init];
    recorderVC.vrbDelegate = self;
    
    //初始化播放器
    self.player = [[AVAudioPlayer alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuDidHide:)
                                                 name:UIMenuControllerDidHideMenuNotification
                                               object:nil];
    
    self.title=xmppvCardTemp.nickname;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"数据获取中，请稍候...";
}



#pragma mark 发送问题
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    if (![MyNetHelper connectedToNetwork]) {
        [self showSendResultLabel:@"网络中断，请检查您的网络状态"];
        self.isSendingMsg=NO;
        return;
    }
    
    if ([text compare:@""]==0) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入问题" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        self.isSendingMsg=NO;
        return;
    }
    
    loadMessageType=kWCMessageTypeLoadLimit;
    [self sendMessageRequest:text];
    [self finishSend];
}

-(void)sendMessageRequest:(NSString *)text
{
    loadMessageType=kWCMessageTypeLoadLimit;
    NSData *data = [text dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *emojiText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self sendMessage:emojiText];
    [MessageSoundEffect playMessageSentSound];
    [self getMessageData];
    [self.tableView reloadData];
}

- (void)sendMessage:(NSString *)text{
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *questionString = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.xmppUserObject.jid];
    [message addBody:questionString];
    [[[self appDelegate] xmppStream] sendElement:message];
    
    //added by cyrus
    
    NSString *myJidUserDef = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCYXMPPMyJid"];
    
    XMPPMessageCoreDataStorageObject *messageObj = (XMPPMessageCoreDataStorageObject *)[NSEntityDescription insertNewObjectForEntityForName:@"XMPPMessageCoreDataStorageObject" inManagedObjectContext:[[self appDelegate] managedObjectContext_message]];
    
    [messageObj setMessageFrom:[[self appDelegate] getJidStrWithoutResource:myJidUserDef]];
    [messageObj setMessageTo:[[self appDelegate] getJidStrWithoutResource:message.toStr]];
    [messageObj setMessageContent:message.body];
    [messageObj setMessageType:[NSNumber numberWithInt:0]];
    //离线消息取时间戳，在线消息取本地时间
    NSDate *date=[[self appDelegate] getDelayStampTime:message];
    if (date) {
        [messageObj setMessageDate:date];
    }else{
        [messageObj setMessageDate:[NSDate date]];
    }
    //判断消息类型是文本、图片还是语音
    [messageObj setMessageType:[NSNumber numberWithInt:[[self appDelegate] getMessageType:message.body]]];
    
    NSError *error;
    
    //托管对象准备好后，调用托管对象上下文的save方法将数据写入数据库
    BOOL isSaveSuccess = [[[self appDelegate] managedObjectContext_message] save:&error];
    
    if (!isSaveSuccess) {
        NSLog(@"保存聊天记录失败: %@,%@",error,[error userInfo]);
    }else {
        NSLog(@"保存聊天记录成功");
    }
    
//    NSString *body = [[message elementForName:@"body"] stringValue];
//    NSString *meesageTo = [[message to]bare];
//    NSArray *strs=[meesageTo componentsSeparatedByString:@"@"];
//    
//    //创建message对象
//    WCMessageObject *msg=[[WCMessageObject alloc]init];
//    [msg setMessageDate:[NSDate date]];
//    [msg setMessageFrom:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID]];
//    
//    [msg setMessageTo:strs[0]];
//    //判断多媒体消息
//    
//    if ([body length]>5)
//    {
//        if ([[body substringToIndex:5]isEqualToString:@"[[1]]"]){
//            [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypeImage]];
//        }else if ([[body substringToIndex:5]isEqualToString:@"[[2]]"]){
//            [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypeVoice]];
//        }else if ([[body substringToIndex:5]isEqualToString:@"[[3]]"]){
//            [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypeHoroscope]];
//        }
//        else{
//            [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypePlain]];
//        }
//    }else
//    {
//        [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypePlain]];
//    }
//    
//    [msg setMessageContent:body];
//    [WCMessageObject save:msg];
//    [msg release];
//    [questionString release];
//    
    loadTotalData=NO;
}




#pragma mark 更多功能
-(void)functionButtonAction:(id)sender
{
    self.inputView.plusButton.tag=0;
    [self.inputView.textView resignFirstResponder];
    UIButton *button=(UIButton *)sender;
    switch (button.tag) {
        case 0:
        case 1:
        {
            [self pickPhoto:sender];
            //拍摄
            break;
        }
        case 2:
        {
            //产品
            refreshForDismiss=YES;
//            ExpertProductSelectViewController_New *productSelect=[[ExpertProductSelectViewController_New alloc] init];
//            productSelect.EPSDelegate=self;
//            [self.navigationController pushViewController:productSelect animated:YES];
//            [productSelect release];
            break;
        }
        case 3:
        {
            //快捷回复
            refreshForDismiss=YES;
//            QuickReplyViewController *quickReply=[[QuickReplyViewController alloc] init];
//            quickReply.QRDelegate=self;
//            [self.navigationController pushViewController:quickReply animated:YES];
//            [quickReply release];
            break;
        }
        case 4:
        {
            //邀请评论
//            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"是否结束本次咨询并扣除所需要积分？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//            alert.tag=20000;
//            [alert show];
//            [alert release];
            break;
        }
        default:
            break;
    }
}

-(void)playImageButton:(id)sender
{
    refreshForDismiss=YES;
    UIButton *button=(UIButton *)sender;
    msgImgGallery.currentIndex=button.tag;
    msgImgGallery.startingIndex=button.tag;
//    if ([(NSString *)[msgArray objectAtIndex:button.tag] compare:@"mall-cbg3.png"]==0) {
//        return;
//    }
    [self.navigationController pushViewController:msgImgGallery animated:YES];
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

-(void)playVoiceButton:(UIButton*)sender
{
    playingVoice=YES;
    
    MessageObject *msg=[messageArray objectAtIndex:sender.tag];
    NSString *content=msg.messageContent;
    NSData *amr=[NSData dataWithBase64EncodedString:[content substringFromIndex:5]];
    NSString *amrFileName=[self getAmrFileName];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyyMMddhhmmssSSS"];
    NSString *wavFileName=[NSString stringWithFormat:@"%@",[formatter stringFromDate:[NSDate date]]];
    
    //转格式
    [VoiceConverter amrToWav:[self readyCacheFile:amrFileName withData:amr] wavSavePath:[VoiceRecorderBaseVC getPathByFileName:wavFileName ofType:@"wav"]];
    self.player = [self.player initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:wavFileName ofType:@"wav"]] error:nil];
    [self.player play];
    UIView *view_temp=[QAContentArray objectAtIndex:sender.tag];
    for (id object in [view_temp subviews]) {
        if ([object isKindOfClass:[UIImageView class]]) {
            UIImageView *img=(UIImageView *)object;
            img.animationRepeatCount=self.player.duration;
            [img startAnimating];
        }
    }
    [self performSelector:@selector(playVoiceEnd) withObject:nil afterDelay:self.player.duration];
}

-(void)playVoiceEnd
{
    playingVoice=NO;
}

#pragma mark - 长按录音
- (void)buttonTouchBegin:(UIButton *)sender
{
    
    if (![MyNetHelper connectedToNetwork]) {
        [self showSendResultLabel:@"网络中断，请检查您的网络状态"];
        self.isSendingMsg=NO;
        return;
    }
    
    if(!self.previousTextViewContentHeight)
		self.previousTextViewContentHeight = self.inputView.textView.contentSize.height;
    
    [self beginAudio:sender];
    NSLog(@"start voice y");
}

- (void)buttonTouchEnd:(UIButton *)sender
{
    [recorderVC endRecord];
    [self endAudio:sender];
    NSLog(@"end voice y");
}

#pragma mark 拍照
-(void)pickPhoto:(id) sender
{
    if(!imgPicker)
    {
        imgPicker=[[UIImagePickerController alloc]init];
        imgPicker.videoQuality=UIImagePickerControllerQualityTypeMedium;
        imgPicker.delegate=self;
        imgPicker.allowsEditing=NO;
    }
    
    UIButton *button=(UIButton *)sender;
    switch (button.tag) {
        case 0:
        {
            //照片
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES];
                }
                imgPicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                UIViewController* controller = self.view.window.rootViewController;
                controller.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.navigationController presentModalViewController:imgPicker animated:YES];
            }else{
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的相册不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            break;
        }
        case 1:
        {
            //拍摄
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES];
                }
                imgPicker.sourceType=UIImagePickerControllerSourceTypeCamera;
                UIViewController* controller = self.view.window.rootViewController;
                controller.modalPresentationStyle = UIModalPresentationFullScreen;
                [controller presentModalViewController:imgPicker animated:YES];
            }else{
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的相机不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"从相册中选取", nil];
                alert.tag=10000;
                [alert show];
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - IBAction
- (void)sendDone:(id)sender {
    
}

- (void)cancelDone:(id)sender {
    [self.messageTextField resignFirstResponder];
    [self.messageTextField setText:nil];
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
#pragma mark 查看用户资料
-(void)checkUserInfo:(id)sender
{
    UIButton *button=(UIButton *)sender;
    switch (button.tag) {
        case 0:
        {
            //专家
            break;
        }
        case 1:
        {
            //用户
            refreshForDismiss=YES;
//            ClientInfoViewController *clientVC=[[ClientInfoViewController alloc] init];
//            clientVC.clientInfoDict=self.clientDict;
//            [self.navigationController pushViewController:clientVC animated:YES];
//            [clientVC release];
            break;
        }
        default:
            break;
    }
}

#pragma mark - 获取文件大小
- (NSInteger) getFileSize:(NSString*) path{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else{
        return -1;
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
        //[self sendMessageRequest:soundString];
        [self sendPressed:nil withText:soundString];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //	return [[[self fetchedResultsController] sections] count];
    return 1;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 62.0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	return [messageArray count];
}


#pragma mark 信息数据接口
//发送人头像
- (UIImage *)userImageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageObject *msg=[messageArray objectAtIndex:indexPath.row];
    if([msg.messageFrom compare:[NSString stringWithFormat:@"%@",self.xmppUserObject.jidStr]]==0)
    {
        //对方
        if(self.targetPhoto)
        {
            return self.targetPhoto;
        }
        else
        {
            return [UIImage imageNamed:@"DefaultPerson.png"];
        }
    }
    else
    {
        
        //我
        NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:[[self appDelegate] xmppStream].myJID];
        
        if (photoData != nil)
        {
            return  [UIImage imageWithData:photoData];
        }
        else
        {
            return [UIImage imageNamed:@"DefaultPerson.png"];
        }
        //        return [UIImage imageNamed:@"menu-avatar"];
    }
}
//信息主体
-(UIView *)cellContentViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageObject *message=[messageArray objectAtIndex:indexPath.row];
    int messageType=message.messageType?[message.messageType intValue]:0;
    if (messageType==2) {
        UIView *view_temp=[QAContentArray objectAtIndex:indexPath.row];
        for (id object in [view_temp subviews]) {
            if ([object isKindOfClass:[UIButton class]]) {
                UIButton *button=(UIButton *)object;
                button.tag=indexPath.row;
            }
        }
    }
    
    if (messageType==0||messageType==1||messageType==2) {
        MyLongPressGestureRecognizer *lpGesture=[[MyLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(contentLongPressAction:)];
        lpGesture.minimumPressDuration=1.0;
        lpGesture.contentTag=indexPath.row;
        UIView *view_temp=[QAContentArray objectAtIndex:indexPath.row];
        [view_temp addGestureRecognizer:lpGesture];
    }
    
    return [QAContentArray objectAtIndex:indexPath.row];
}
//信息高度
- (CGFloat)cellHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[cellHeightArray objectAtIndex:indexPath.row] floatValue];
}
//发送时间
- (NSString *)contentSendTimeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [dateFormatter stringFromDate:((MessageObject*)[messageArray objectAtIndex:indexPath.row]).messageDate];
}
//信息类型--专家/个人
- (int)contentTypeTimeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageObject *msg=[messageArray objectAtIndex:indexPath.row];
    if([msg.messageFrom compare:[NSString stringWithFormat:@"%@",self.xmppUserObject.jidStr]]==0)
    {
        //对方
        return 1;
    }
    else
    {
        //我
        return 0;
    }
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    WCMessageObject *msg=[msgRecords objectAtIndex:indexPath.row];
    
    XMPPMessageCoreDataStorageObject *message = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    NSString *content=message.messageContent;
    if([content length]>5)
    {
        if ([[content substringToIndex:5]compare:@"[[1]]"]==0) {
            //            content=@"语音文件";
        }
        else if ([[content substringToIndex:5]compare:@"[[2]]"]==0) {
            content=@"语音文件";
            //        NSData *audioData = [[content substringFromIndex:3] base64DecodedData];
        }
        else
        {
            NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
            NSString *emojiData = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
            content=emojiData;
        }
    }
    else
    {
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        NSString *emojiData = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        content=emojiData;
    }
    
    return content;
}

- (UIImage *)contentImageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    XMPPMessageArchiving_Message_CoreDataObject *object = [self.dataArray objectAtIndex:indexPath.row];
    //    NSMutableString *showString = [[NSMutableString alloc] init];
    //    [showString appendFormat:@"body:%@\n",object.body];
    
    MessageObject *messageObj=[messageArray objectAtIndex:indexPath.row];
    
    NSString *content=messageObj.messageContent;
    if([content length]>5)
    {
        if ([[content substringToIndex:5]compare:@"[[1]]"]==0)
        {
            //            content=@"语音文件";
            return [Photo string2Image:[content substringFromIndex:5]];
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

- (NSString *)dateForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MessageObject *messageObj=[messageArray objectAtIndex:indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    
    return [formatter stringFromDate:messageObj.messageDate];
}

#pragma mark 长按手势
-(void)contentLongPressAction:(UIGestureRecognizer *)gestureRecognizer
{
    
    self.isLongPressOnCell=YES;
    MyLongPressGestureRecognizer *lpGesture=(MyLongPressGestureRecognizer *)gestureRecognizer;
    if (lpGesture.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (lpGesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"MyLongPressGestureRecognizer:%d",lpGesture.contentTag);
        longPressCellIndex=lpGesture.contentTag;
        MessageObject *msg=[messageArray objectAtIndex:lpGesture.contentTag];
        int messageType=msg.messageType?[msg.messageType intValue]:0;
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if (messageType==0||messageType==3) {
            UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyCell:)];
            UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteCell:)];
            [menu setMenuItems:[NSArray arrayWithObjects:copy, delete, nil]];
        }else if (messageType==1) {
            UIMenuItem *save = [[UIMenuItem alloc] initWithTitle:@"保存" action:@selector(saveCellImg:)];
            UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteCell:)];
            [menu setMenuItems:[NSArray arrayWithObjects:save, delete, nil]];
        }else if (messageType==2){
            UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteCell:)];
            [menu setMenuItems:[NSArray arrayWithObjects: delete, nil]];
        }
        //尺寸和添加到哪里
//        ExpertChatCell_New *targetView=(ExpertChatCell_New *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lpGesture.contentTag inSection:0]];
//        
//        [self.inputView.textView resignFirstResponder];
//        [targetView becomeFirstResponder];
//        
//        [menu setTargetRect:targetView.qaContentView.frame inView: targetView];
//        [menu setMenuVisible: YES animated: YES];
        
    }
    
}


//什么样的操作会被响应
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action==@selector(saveCellImg:)) {
        return YES;
    }else if (action==@selector(copyCell:)){
        return YES;
    }else if (action==@selector(deleteCell:)){
        return YES;
    }else{
        return NO;
    }
}

-(void)menuDidHide:(NSNotification *)notification
{
    if (self.isLongPressOnCell) {
//        ExpertChatCell_New *targetView=(ExpertChatCell_New *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:longPressCellIndex inSection:0]];
//        self.isLongPressOnCell=NO;
//        [self.inputView removeFromSuperview];
//        self.inputView=nil;
//        [targetView resignFirstResponder];
//        [self setUpInputView];
    }
    
    
    //[self.inputView.textView b  ecomeFirstResponder];
}

- (void)saveCellImg:(id)sender
{
    MessageObject *msg=[messageArray objectAtIndex:longPressCellIndex];
    UIImage *sendImage=[Photo string2Image:[msg.messageContent substringFromIndex:5]];
    UIImageWriteToSavedPhotosAlbum(sendImage, nil, nil,nil);
    if (!HUD) {
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
    }
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.delegate = self;
    HUD.labelText = @"保存成功";
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.0];
}

- (void)copyCell:(id)sender
{
    MessageObject *msg=[messageArray objectAtIndex:longPressCellIndex];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setStrings:[NSArray arrayWithObjects:msg.messageContent, nil]];
}

- (void)deleteCell:(id)sender
{
    MessageObject *msg=[messageArray objectAtIndex:longPressCellIndex];
//    BOOL success=[MessageObject deleteLocalDataByMsgId:[NSString stringWithFormat:@"%d",[msg.messageId intValue]]];
//    if (success) {
//        loadTotalData=NO;
//        loadMessageType=kWCMessageTypeLoadAll;
//        [self getMessageData];
//    }
    [msgImgGallery reloadGallery];
    
}

#pragma mark 重置屏幕窗口
-(void)reSetWindowsFrame
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] keyWindow].clipsToBounds=YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [[UIApplication sharedApplication] keyWindow].frame=CGRectMake(0,20,[[UIApplication sharedApplication] keyWindow].frame.size.width,[[UIApplication sharedApplication] keyWindow].frame.size.height-20.0);
}

#pragma mark UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    if (![MyNetHelper connectedToNetwork]) {
        [self showSendResultLabel:@"网络中断，请检查您的网络状态"];
        self.isSendingMsg=NO;
        return;
    }
    
    refreshForDismiss=NO;
    //UIImage  * chosedImage=[info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    UIImage *image_temp = [Photo scaleImage:image toWidth:240.0 toHeight:image.size.height*240.0/image.size.width];
    NSData* pictureData = UIImageJPEGRepresentation(image_temp,1.0);
    
    XMPPMessage *xmppmessage = [XMPPMessage messageWithType:@"chat" to:self.toJID];
    NSString *meesageTo = [[xmppmessage to]bare];
    NSArray *strs=[meesageTo componentsSeparatedByString:@"@"];

    NSString *myJidUserDef = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCYXMPPMyJid"];
    
    MessageObject *message=[[MessageObject alloc]init];
//    [message setMessageId:[NSNumber numberWithInt:0]];
    NSString *str_temp=[NSString stringWithFormat:@"[[1]]mall-cbg3.png"];
    [message setMessageContent:str_temp];
    [message setMessageDate:[NSDate date]];
    [message setMessageFrom:[[self appDelegate] getJidStrWithoutResource:myJidUserDef]];
    [message setMessageTo:[[self appDelegate] getJidStrWithoutResource:meesageTo]];
    [message setMessageType:[NSNumber numberWithInt:1]];
    [messageArray addObject:message];
    
//    NSArray *imageArray=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[msgRecords count]-1],pictureData, nil];
//    [NSThread detachNewThreadSelector:@selector(sendChatImg:) toTarget:self withObject:imageArray];
    
    
    
    XMPPMessageCoreDataStorageObject *messageObj = (XMPPMessageCoreDataStorageObject *)[NSEntityDescription insertNewObjectForEntityForName:@"XMPPMessageCoreDataStorageObject" inManagedObjectContext:[[self appDelegate] managedObjectContext_message]];
    
    [messageObj setMessageFrom:[[self appDelegate] getJidStrWithoutResource:myJidUserDef]];
    [messageObj setMessageTo:[[self appDelegate] getJidStrWithoutResource:meesageTo]];
    [messageObj setMessageContent:str_temp];
    [messageObj setMessageType:[NSNumber numberWithInt:1]];
    [messageObj setMessageDate:[NSDate date]];
    
    NSError *error;
    
    //托管对象准备好后，调用托管对象上下文的save方法将数据写入数据库
    BOOL isSaveSuccess = [[[self appDelegate] managedObjectContext_message] save:&error];
    
    if (!isSaveSuccess) {
        NSLog(@"保存聊天记录失败: %@,%@",error,[error userInfo]);
    }else {
        NSLog(@"保存聊天记录成功");
    }

    
    
//    [self setQAContentArrayAction:[msgRecords lastObject]];
    [self.tableView reloadData];
    if ([messageArray count]>0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    [picker dismissModalViewControllerAnimated:YES];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
        [self performSelector:@selector(reSetWindowsFrame) withObject:nil afterDelay:0.3];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [picker dismissModalViewControllerAnimated:YES];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
        [self performSelector:@selector(reSetWindowsFrame) withObject:nil afterDelay:0.3];
    }
}

#pragma mark 发送聊天图片
-(void)sendChatImg:(NSArray*)imageArray
{
//    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
//    int index=[[imageArray objectAtIndex:0] intValue];//数组中的位置
//    NSString *imgNameString=[HttpRequestClass XMPPMessageImageUpload:[imageArray objectAtIndex:1]];
//    if ([imgNameString compare:@""]!=0) {
//        [msgRecords removeObjectAtIndex:index];
//        [QAContentArray removeObjectAtIndex:index];
//        [cellHeightArray removeObjectAtIndex:index];
//        [self performSelectorOnMainThread:@selector(sendChatImageSuccess:) withObject:imgNameString waitUntilDone:YES];
//        
//    }
//    [pool release];
//    
//    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:[self.clientDict objectForKey:@"OId"],@"oId",[ExpertInfoSingleton sharedInstance].expertId,@"expertId",@"false",@"isTopicEnd", nil];
//    [NSThread detachNewThreadSelector:@selector(expertChatPayConfirm:) toTarget:self withObject:dict];
}

-(void)sendChatImageSuccess:(NSString *)imageName
{
//    [msgArray removeLastObject];
//    //[msgArray addObject:imageName];
//    NSMutableString *imageString = [[NSMutableString alloc]initWithString:@"[[1]]"];
//    [imageString appendString:imageName];
//    [self sendMessageRequest:imageString];
//    [imageString release];
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==10000) {
        if (buttonIndex==1) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES];
                }
                imgPicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                UIViewController* controller = self.view.window.rootViewController;
                controller.modalPresentationStyle = UIModalPresentationFullScreen;
                [controller presentModalViewController:imgPicker animated:YES];
            }else{
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的相册不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }else if(alertView.tag==20000){
        if (buttonIndex==1) {
//            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:[self.clientDict objectForKey:@"OId"],@"oId",[ExpertInfoSingleton sharedInstance].expertId,@"expertId",@"true",@"isTopicEnd", nil];
//            [self showLoadingView];
//            [NSThread detachNewThreadSelector:@selector(expertChatPayConfirm:) toTarget:self withObject:dict];
        }
    }
}

#pragma mark - FGalleryViewControllerDelegate Methods

- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
	return [messageImageArray count];
}


- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
	return FGalleryPhotoSourceTypeNetwork;
}


- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    NSString *caption=@"";
    if( gallery == msgImgGallery) {
        caption = @"";
    }
	return caption;
}
- (NSString*)photoGallery:(FGalleryViewController*)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index
{
    return [messageImageArray objectAtIndex:index];
}

- (UIImage *)photoGallery:(FGalleryViewController*)gallery atIndex:(NSUInteger)index
{
    return [messageImageArray objectAtIndex:index];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
