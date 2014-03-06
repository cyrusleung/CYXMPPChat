//
//  RosterViewController.h
//  iPhoneXMPP
//
//  Created by FatKa Leung on 14-2-13.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface RosterViewController : UITableViewController <ChatDelegate,NSFetchedResultsControllerDelegate,MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
	NSFetchedResultsController *fetchedResultsController;
}

@end
