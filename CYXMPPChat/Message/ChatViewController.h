//
//  ChatViewController.h
//  CYXMPPChat
//
//  Created by FatKa Leung on 14-2-16.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MessagesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "ChatVoiceRecorderVC.h"
#import "VoiceConverter.h"
#import <CoreData/CoreData.h>
#import "MessageObject.h"
#import "FileHelpers.h"
#import "ImageCacher.h"
#import "Photo.h"
#import "RTLabel.h"
#import "FGalleryViewController.h"

@interface ChatViewController : MessagesViewController<ChatDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,MBProgressHUDDelegate,NSFetchedResultsControllerDelegate>
{
    MBProgressHUD *HUD;
    NSFetchedResultsController *fetchedResultsController;
}

@property (retain, nonatomic) UIImage *targetPhoto;
@property (strong, nonatomic) UITextField *messageTextField;
@property (retain, nonatomic) ChatVoiceRecorderVC  *recorderVC;
@property (retain, nonatomic) AVAudioPlayer *player;

@property (nonatomic,strong) XMPPUserCoreDataStorageObject *xmppUserObject;

@end
