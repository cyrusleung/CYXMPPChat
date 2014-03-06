//
//  RosterViewController.m
//  iPhoneXMPP
//
//  Created by FatKa Leung on 14-2-13.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import "RosterViewController.h"
#import "XMPPvCardTemp.h"
#import "RosterCell.h"
#import "VCardViewController.h"
#import "LoginViewController.h"
#import "ChatViewController.h"



@interface RosterViewController ()

@end

@implementation RosterViewController

- (AppDelegate *)appDelegate
{
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.chatDelegate = self;
	return delegate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
//    [self queryFromDB:nil];
//	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
//	titleLabel.backgroundColor = [UIColor clearColor];
//	titleLabel.textColor = [UIColor whiteColor];
//	titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
//	titleLabel.numberOfLines = 1;
//	titleLabel.adjustsFontSizeToFitWidth = YES;
//	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
//	titleLabel.textAlignment = NSTextAlignmentCenter;
    
//	if ([[self appDelegate] connect])
//	{
//        [self setTitle:@"我的好友"];
//        
//	} else
//	{
//        [self setTitle:@"未连接"];
//	}
    
    [self setTitle:@"我的好友"];
	
    
//	[titleLabel sizeToFit];
//    
//	self.navigationItem.titleView = titleLabel;
}

- (void)viewWillDisappear:(BOOL)animated
{
//	[[self appDelegate] disconnect];
//	[[[self appDelegate] xmppvCardTempModule] removeDelegate:self];
	
	[super viewWillDisappear:animated];
}

#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
//        fetchedResultsController = nil;
//    }
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        HUD.delegate = self;
        HUD.labelText = @"连接中，请稍候...";
        [HUD show:YES];
        
		NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subscription != %@", @"none"];
        
        
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
        
        [fetchRequest setPredicate:predicate];
		[fetchRequest setFetchBatchSize:10];
        
        
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"sectionNum"
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
        
        [HUD hide:YES];
		
		
		NSError *error = nil;
        
		if (![fetchedResultsController performFetch:&error])
		{
//			DDLogError(@"Error performing fetch: %@", error);
		}
        
	}
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[[self tableView] reloadData];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[[self fetchedResultsController] sections] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
		int section = [sectionInfo.name intValue];
		switch (section)
		{
			case 0  : return @"在线上";
			case 1  : return @"离开中";
			default : return @"已下线";
		}
	}
	
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *contentCellIndentifier=@"RosterCell";
    RosterCell *cell=[tableView dequeueReusableCellWithIdentifier:contentCellIndentifier];
    if (!cell) {
        cell=[[RosterCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:contentCellIndentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleBlue;
        cell.accessoryType=UITableViewCellAccessoryNone;
        cell.backgroundColor=[UIColor clearColor];
    }
	
	XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    //加载vcard资料
    XMPPvCardCoreDataStorage *xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    XMPPvCardTempModule *xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    XMPPvCardTemp *xmppvCardTemp =[xmppvCardTempModule vCardTempForJID:user.jid  shouldFetch:YES];
    
    if([xmppvCardTemp.nickname length]>0)
    {
        cell.userNameLabel.text=xmppvCardTemp.nickname;
    }
    else
    {
        cell.userNameLabel.text=user.jidStr;
    }
//    cell.userNameLabel.text=user.jidStr;
    
    if (user.photo != nil)
	{
		cell.userPhotoImageView.image = user.photo;
	}
	else
	{
		NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
		if (photoData != nil)
			cell.userPhotoImageView.image = [UIImage imageWithData:photoData];
		else
			cell.userPhotoImageView.image = [UIImage imageNamed:@"DefaultPerson.png"];
	}
    
    cell.messageCountBackgroundImageView.hidden=YES;
//    cell.messageCountLabel.text=@"2";
    NSString *target=[[self appDelegate] getJidStrWithoutResource:user.jidStr];
//    user.jidStr;
//    
//    NSRange range=[target rangeOfString:@"/"];
//    if(range.location!=NSNotFound)
//    {
//        target=[target substringToIndex:range.location];
//    }
    cell.messageContentLabel.text=[self queryLastestMessage:target];
    
//    cell.messageContentLabel.text=[self queryLastestMessage:<#(NSString *)#>];
//    cell.messageDateLabel.text=@"10:20";
    
//    cell.userPhotoImageButton.tag=indexPath.row;
//    [cell.userPhotoImageButton addTarget:self action:@selector(goVCard:) forControlEvents:UIControlEventTouchUpInside];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

//    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    
//    VCardViewController *controller=[[VCardViewController alloc] init];
//    controller.userVCard=user;
//    [self.navigationController pushViewController:controller animated:YES];
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    
    XMPPvCardCoreDataStorage *xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    XMPPvCardTempModule *xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    XMPPvCardTemp *xmppvCardTemp =[xmppvCardTempModule vCardTempForJID:user.jid  shouldFetch:YES];
    
//    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
//    XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
//    [newvCardTemp setUrl:@"nick"];
//    [xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
    
//    xmppvCardTemp.url=@"csdn.net";
//    [self updatePhoto];
//    [xmppvCardTempModule updateMyvCardTemp:xmppvCardTemp];
    
//    [self queryFromDB:nil];
//    [self changePassword];
    
    ChatViewController *controller=[[ChatViewController alloc] init];
    controller.xmppUserObject=user;
    if (user.photo != nil)
	{
		controller.targetPhoto = user.photo;
	}
	else
	{
		NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
		if (photoData != nil)
        {
			controller.targetPhoto = [UIImage imageWithData:photoData];
        }
		else
        {
			controller.targetPhoto = [UIImage imageNamed:@"DefaultPerson.png"];
        }
	}
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark 查找最后一条聊天记录
- (NSString *)queryLastestMessage:(NSString *)target {
    //创建取回数据请求
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //设置要检索哪种类型的实体对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"inManagedObjectContext:[[self appDelegate] managedObjectContext_message]];
    //设置请求实体
    [fetchRequest setEntity:entity];
    //指定对结果的排序方式
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:NO];
    NSArray *sortDescriptions = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageFrom==%@  or  messageTo==%@ ",target, target];
    [fetchRequest setSortDescriptors:sortDescriptions];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:1];
    
    NSError *error = nil;
    //执行获取数据请求，返回数组
//    NSArray *fetchResults = [[[self appDelegate] managedObjectContext_message] executeFetchRequest:fetchRequest error:&error];
    
//    User *result = nil;
    
//    if ([fetchResults count]>0)
//        result = [fetchResults objectAtIndex:0];
    
    
    NSMutableArray *mutableFetchResult = [[[[self appDelegate] managedObjectContext_message] executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    
    NSMutableArray *entries=[[NSMutableArray alloc]init];
    entries = mutableFetchResult;
    NSString *message;
    if([entries count]>0)
    {
        message=[[entries objectAtIndex:0] messageContent];
    }
    else
    {
        message=@"";
    }
    return  message;
    
}

- (void)queryFromDB:(NSString *)target {
    //创建取回数据请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设置要检索哪种类型的实体对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"inManagedObjectContext:[[self appDelegate] managedObjectContext_message]];
    //设置请求实体
    [request setEntity:entity];
    //指定对结果的排序方式
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageDate"ascending:NO];
    NSArray *sortDescriptions = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptions];
    
    NSError *error = nil;
    //执行获取数据请求，返回数组
    NSMutableArray *mutableFetchResult = [[[[self appDelegate] managedObjectContext_message] executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    
    NSMutableArray *entries=[[NSMutableArray alloc]init];
    entries = mutableFetchResult;
    
    NSLog(@"The count of entry:%i",[entries count]);
    
    for (XMPPMessageCoreDataStorageObject *entry in entries) {
        NSLog(@"From:%@---To:%@---content:%@",entry.messageFrom,entry.messageTo,entry.messageContent);
    }
    
}

//-(void)changePassword
//{
//    NSString *send=@"<iq type='set' to='xmpp.yw258.com' id='change1'><query xmlns='jabber:iq:register'><username>aaaaaa</username><password>bbbbbb</password></query></iq>";
//    
//    //生成<body>文檔
//    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
//    [body setStringValue:message];
//    
//    //生成XML消息文檔
//    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
//    //消息類型
//    [mes addAttributeWithName:@"type" stringValue:@"chat"];
//    //發送给誰
//    [mes addAttributeWithName:@"to" stringValue:chatWithUser];
//    //由誰發送
//    [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID]];
//    //組合
//    [mes addChild:body];
//}

- (void)updatePassword
{
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:@"xmpp.yw258.com"];
    [iq addAttributeWithName:@"id" stringValue:@"change1"];
    DDXMLNode *username=[DDXMLNode elementWithName:@"username" stringValue:@"aaaaaa"];
    DDXMLNode *password=[DDXMLNode elementWithName:@"password" stringValue:@"123456"];
    [query addChild:username];
    [query addChild:password];
    [iq addChild:query];
    [[[self appDelegate] xmppStream] sendElement:iq];
}

-(void)updatePhoto
{
    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:
                              @"vcard-temp"];
    NSXMLElement *photoXML = [NSXMLElement elementWithName:@"PHOTO"];
    NSXMLElement *typeXML = [NSXMLElement elementWithName:@"TYPE"
                                              stringValue:@"image/jpeg"];
    UIImage *image=[UIImage imageNamed:@"DefaultPerson.png"];
    NSData *dataFromImage =UIImagePNGRepresentation(image);
    //UIImageJPEGRepresentation(image, 0.7f);
    NSXMLElement *binvalXML = [NSXMLElement elementWithName:@"BINVAL"
                                                stringValue:[dataFromImage base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    [photoXML addChild:typeXML];
    [photoXML addChild:binvalXML];
    [vCardXML addChild:photoXML];
    XMPPvCardTemp *myvCardTemp = [[[self appDelegate] xmppvCardTempModule]
                                  myvCardTemp];
    if (myvCardTemp) {
        [myvCardTemp setPhoto:dataFromImage];
        [[[self appDelegate] xmppvCardTempModule] updateMyvCardTemp
         :myvCardTemp];
    }
    else{
        XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement
                                       :vCardXML]; 
        [[[self appDelegate] xmppvCardTempModule] updateMyvCardTemp 
         :newvCardTemp];
    }
}
//-(void)goVCard:(id)sender
//{
//    UIButton *button=(UIButton *)sender;
//    int row=button.tag;
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];;
//    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    
//    NSLog(@"%@",user.displayName);
//    
//    VCardViewController *controller=[[VCardViewController alloc] init];
//    controller.userVCard=user;
//    [self.navigationController pushViewController:controller animated:YES];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.navigationItem setHidesBackButton:YES];
    
    UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame=CGRectMake(0, 0, 44, 44);
//    [leftButton setImage:[UIImage imageNamed:@"nav-back.png"] forState:UIControlStateNormal];
//    [leftButton setBackgroundImage:[UIImage imageNamed:@"nav-btn-bg"] forState:UIControlStateHighlighted];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton setTitle:@"退出" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarItem=[[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem=rightBarItem;
    
    [self appDelegate];
    
    
}

-(void)logout:(id)sender
{
    
    [[self appDelegate] disconnect];
	[[[self appDelegate] xmppvCardTempModule] removeDelegate:self];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kCYXMPPMyJid"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kCYXMPPMyPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getNewMessage:(AppDelegate *)appD Message:(XMPPMessage *)message
{
    
//    loadMessageType=kWCMessageTypeLoadLimit;
//    [self getMessageData];
    [self.tableView reloadData];
//    if ([messageArray count]>0) {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
