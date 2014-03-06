//
//  AppDelegate.m
//  CYXMPPChat
//
//  Created by FatKa Leung on 14-2-15.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import "AppDelegate.h"
#import "RosterViewController.h"
#import "LoginViewController.h"

#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#import <CFNetwork/CFNetwork.h>

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


@interface AppDelegate()

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AppDelegate

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

@synthesize chatDelegate;

@synthesize window;
@synthesize navigationController;
@synthesize loginViewController;

@synthesize persistentStoreCoordinator,managedObjectModel,managedObjectContext;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Configure logging framework
	
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Setup the XMPP stream
    
	[self setupStream];
    
	// Setup the view controllers
    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    LoginViewController *loginVC=[[LoginViewController alloc] initWithStyle:UITableViewStyleGrouped];;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = self.navigationController;
	[window makeKeyAndVisible];
    
    //已登陆过切未退出的，再次打开应用时自动登录，否则跳转登录页面
    NSString *myJidUserDef = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCYXMPPMyJid"];
    NSString *myPasswordUserDef = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCYXMPPMyPassword"];
    
    if (myJidUserDef && myPasswordUserDef)
    {
        NSLog(@"已经登录");
        [self connect];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			RosterViewController *rosterVC = [[RosterViewController alloc] init];
            [self.navigationController pushViewController:rosterVC animated:YES];
		});
    }
    else
    {
        NSLog(@"还没登录");
        
    }
    
	return YES;
}

- (void)dealloc
{
	[self teardownStream];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

-(NSManagedObjectContext *)managedObjectContext_message
{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator =[self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc]init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return managedObjectContext;
}

-(NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return managedObjectModel;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    //得到数据库的路径
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    //CoreData是建立在SQLite之上的，数据库名称需与Xcdatamodel文件同名
    NSURL *storeUrl = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", @"XMPPMessage"]]];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    
    return persistentStoreCoordinator;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
	xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.
	
    //	[xmppStream setHostName:@"talk.google.com"];
    //	[xmppStream setHostPort:5222];
	
    
	// You may need to alter these settings depending on the server you're connecting to
	allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
}

- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
	
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect
{
    NSLog(@"connecting...");
	if (![xmppStream isDisconnected]) {
		return YES;
	}
    
    NSString *myJidUserDef = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCYXMPPMyJid"];
    NSString *myPasswordUserDef = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCYXMPPMyPassword"];
    
	//
	// If you don't want to use the Settings view to set the JID,
	// uncomment the section below to hard code a JID and password.
	//
	// myJID = @"user@gmail.com/xmppframework";
	// myPassword = @"";
	
	if (myJidUserDef == nil || myPasswordUserDef == nil) {
		return NO;
	}
    
    //edited by cyrus
    [xmppStream setMyJID:[XMPPJID jidWithString:myJidUserDef resource:@"iPhone"]];
    
	password = myPasswordUserDef;
    
	NSError *error = nil;
	if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
        
		DDLogError(@"Error connecting: %@", error);
        
		return NO;
	}
    
	return YES;
}

- (void)disconnect
{
    [xmppStream disconnectAfterSending];//登出
	[self goOffline];
//	[xmppStream disconnect];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIApplicationDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [self connect];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if (xmppStream.isConnected) {
        [self disconnect];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store
	// enough application state information to restore your application to its current state in case
	// it is terminated later.
	//
	// If your application supports background execution,
	// called instead of applicationWillTerminate: when the user quits.
    
    //added by cyrus
    NSError *error;
    if ([xmppRosterStorage mainThreadManagedObjectContext] != nil) {
        //hasChanges方法是检查是否有未保存的上下文更改，如果有，则执行save方法保存上下文
        if ([[xmppRosterStorage mainThreadManagedObjectContext] hasChanges] && ![[xmppRosterStorage mainThreadManagedObjectContext] save:&error]) {
            NSLog(@"Error: %@,%@",error,[error userInfo]);
            abort();
        }
    }
	
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
#if TARGET_IPHONE_SIMULATOR
	DDLogError(@"The iPhone simulator does not process background network traffic. "
			   @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif
    
	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
	{
		[application setKeepAliveTimeout:600 handler:^{
			
			DDLogVerbose(@"KeepAliveHandler");
			
			// Do other keep alive stuff here.
		}];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
	
	NSError *error = nil;
	
	if (![[self xmppStream] authenticateWithPassword:password error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	return NO;
}



- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
	// A simple example of inbound message handling.
    
    //        NSLog(@"from:%@",message.fromStr);
    //        NSLog(@"to:%@",message.toStr);
    //        NSLog(@"msg:%@",message.body);
    //		NSString *body = [[message elementForName:@"body"] stringValue];
    //		NSString *displayName = [user displayName];
    
//    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
//                                                             xmppStream:xmppStream
//                                                   managedObjectContext:[self managedObjectContext_roster]];
    
	if ([message isChatMessageWithBody])
	{
        //added by cyrus
        XMPPMessageCoreDataStorageObject *messageObj = (XMPPMessageCoreDataStorageObject *)[NSEntityDescription insertNewObjectForEntityForName:@"XMPPMessageCoreDataStorageObject" inManagedObjectContext:[self managedObjectContext_message]];
        
        [messageObj setMessageFrom:[self getJidStrWithoutResource:message.fromStr]];
        [messageObj setMessageTo:[self getJidStrWithoutResource:message.toStr]];
        [messageObj setMessageContent:message.body];
        [messageObj setMessageType:[NSNumber numberWithInt:0]];
        //离线消息取时间戳，在线消息取本地时间
        NSDate *date=[self getDelayStampTime:message];
        if (date) {
            [messageObj setMessageDate:date];
        }else{
            [messageObj setMessageDate:[NSDate date]];
        }
        //判断消息类型是文本、图片还是语音
        [messageObj setMessageType:[NSNumber numberWithInt:[self getMessageType:message.body]]];
        
        NSError *error;
        
        //托管对象准备好后，调用托管对象上下文的save方法将数据写入数据库
        BOOL isSaveSuccess = [[self managedObjectContext_message] save:&error];
        
        if (!isSaveSuccess) {
            NSLog(@"保存聊天记录失败: %@,%@",error,[error userInfo]);
        }else {
            NSLog(@"保存聊天记录成功");
        }
        
        
		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
		{
//			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message.fromStr
//                                                                message:message.body
//                                                               delegate:nil
//                                                      cancelButtonTitle:@"Ok"
//                                                      otherButtonTitles:nil];
//			[alertView show];
            
            if ([self.chatDelegate respondsToSelector:@selector(getNewMessage:Message:)]) {
                [self.chatDelegate getNewMessage:self Message:message];
            }
		}
		else
		{
			// We are not active, so use a local notification instead
			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
			localNotification.alertAction = @"Ok";
			localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",message.fromStr,message.body];
            
			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
		}
        
	}
}

#pragma mark common function
-(NSString *)getJidStrWithoutResource:(NSString *)target;
{
    NSRange range=[target rangeOfString:@"/"];
    if(range.location!=NSNotFound)
    {
        target=[target substringToIndex:range.location];
    }
    return target;
}

-(int)getMessageType:(NSString *)message
{
    if ([message length]>5)
    {
        if ([[message substringToIndex:5]isEqualToString:@"[[1]]"]) {
            return kCYMessageTypeImage;
        }else if ([[message substringToIndex:5]isEqualToString:@"[[2]]"]) {
            return kCYMessageTypeVoice;
        }else{
            return kCYMessageTypePlain;
        }
    }else{
        return kCYMessageTypePlain;
    }
}

-(NSDate *)getDelayStampTime:(XMPPMessage *)message
{
    XMPPElement *delay=(XMPPElement *)[message elementForName:@"delay"];
    if (delay) {
        NSString *timeString=[[(XMPPElement *)[message elementForName:@"delay"] attributeForName:@"stamp"] stringValue];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSArray *arr=[timeString componentsSeparatedByString:@"T"];
        NSString *dateStr=[arr objectAtIndex:0];
        NSString *timeStr=[[[arr objectAtIndex:1] componentsSeparatedByString:@"."] objectAtIndex:0];
        NSDate *localDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@T%@+0000",dateStr,timeStr]];
        return localDate;
    }else{
        return nil;
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    NSLog(@"really error");
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
	                                                         xmppStream:xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];
	
	NSString *displayName = [user displayName];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;
	
	if (![displayName isEqualToString:jidStrBare])
	{
		body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
	}
	else
	{
		body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
	}
	
	
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
		                                                    message:body
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Not implemented"
		                                          otherButtonTitles:nil];
		[alertView show];
	}
	else
	{
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"Not implemented";
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
	
}

@end

