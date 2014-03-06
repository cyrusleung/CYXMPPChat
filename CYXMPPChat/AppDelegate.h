//
//  AppDelegate.h
//  CYXMPPChat
//
//  Created by FatKa Leung on 14-2-15.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "XMPPFramework.h"

enum kCYMessageType {
    kCYMessageTypePlain = 0,
    kCYMessageTypeImage = 1,
    kCYMessageTypeVoice =2
};

enum kCYMessageCellStyle {
    kCYMessageCellStyleMe = 0,
    kCYMessageCellStyleOther = 1,
    kCYMessageCellStyleMeWithImage=2,
    kCYMessageCellStyleOtherWithImage=3
};

@protocol ChatDelegate;

@class LoginViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate,XMPPRosterDelegate>
{
	XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
	
	NSString *password;
    //
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
    //
	BOOL isXmppConnected;
    
    UIWindow *window;
	UINavigationController *navigationController;
    LoginViewController *loginViewController;
	
}

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) LoginViewController *loginViewController;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;
//added by cyrus
- (NSManagedObjectContext *)managedObjectContext_message;

//数据模型对象
@property(strong,nonatomic) NSManagedObjectModel *managedObjectModel;
//上下文对象
@property(strong,nonatomic) NSManagedObjectContext *managedObjectContext;
//持久性存储区
@property(strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
//初始化Core Data使用的数据库
-(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

//managedObjectModel的初始化赋值函数
-(NSManagedObjectModel *)managedObjectModel;

//managedObjectContext的初始化赋值函数
-(NSManagedObjectContext *)managedObjectContext;

-(NSString *)getJidStrWithoutResource:(NSString *)target;
-(int)getMessageType:(NSString *)message;
-(NSDate *)getDelayStampTime:(XMPPMessage *)message;

- (BOOL)connect;
- (void)disconnect;

@property (nonatomic,strong) id<ChatDelegate> chatDelegate;

@end


@protocol ChatDelegate <NSObject>

@optional
-(void)friendStatusChange:(AppDelegate *)appD Presence:(XMPPPresence *)presence;
-(void)getNewMessage:(AppDelegate *)appD Message:(XMPPMessage *)message;
-(void)showMsgTips:(AppDelegate *)appD Message:(NSString *)message;
@end

