//
//  VCardViewController.h
//  iPhoneXMPP
//
//  Created by FatKa Leung on 14-2-13.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "XMPPvCardTemp.h"
#import "XMPPUserCoreDataStorageObject.h"

@interface VCardViewController : UIViewController

@property (nonatomic,retain)XMPPUserCoreDataStorageObject *userVCard;

@end
