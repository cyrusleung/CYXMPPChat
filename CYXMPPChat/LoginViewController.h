//
//  LoginViewController.h
//  CYXMPPChat
//
//  Created by FatKa Leung on 14-2-15.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import <UIKit/UIKit.h>

//extern NSString *const kXMPPmyJID;
//extern NSString *const kXMPPmyPassword;

@interface LoginViewController : UITableViewController

@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;

@end
