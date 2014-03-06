//
//  LoginViewController.m
//  CYXMPPChat
//
//  Created by FatKa Leung on 14-2-15.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "RosterViewController.h"
#import "WTStatusBar.h"

@interface LoginViewController ()<UITextFieldDelegate>

@end

@implementation LoginViewController

@synthesize usernameTextField, passwordTextField;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"登录";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    [self setTitle:@"登录"];
//    [self.view setBackgroundColor:[UIColor whiteColor]];
//    [self.navigationItem setHidesBackButton:YES];
//    
//    UILabel *jidLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 100, 70, 25)];
//    [jidLabel setText:@"Account"];
//    [jidLabel setFont:[UIFont systemFontOfSize:14]];
//    [self.view addSubview:jidLabel];
//    
//    jidField=[[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(jidLabel.frame), 100, 200, 25)];
//    [jidField setPlaceholder:@"user@example.com"];
//    [jidField setBorderStyle:UITextBorderStyleRoundedRect];
//    [self.view addSubview:jidField];
//    
//    UILabel *passwordLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(jidLabel.frame)+10, 70, 25)];
//    [passwordLabel setText:@"Password"];
//    [passwordLabel setFont:[UIFont systemFontOfSize:14]];
//    [self.view addSubview:passwordLabel];
//    
//    passwordField=[[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(passwordLabel.frame), CGRectGetMaxY(jidLabel.frame)+10, 200, 25)];
//    [passwordField setBorderStyle:UITextBorderStyleRoundedRect];
//    [self.view addSubview:passwordField];
//    
//    UIButton *doneBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
//    [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [doneBtn setFrame:CGRectMake(20, CGRectGetMaxY(passwordLabel.frame)+10, 60, 20)];
//    [doneBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:doneBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *myJidUserDef = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCYXMPPMyJid"];
    NSString *myPasswordUserDef = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCYXMPPMyPassword"];
    usernameTextField.text = myJidUserDef;
    passwordTextField.text = myPasswordUserDef;
}

#pragma mark - my methods
- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *myJidUserDef = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCYXMPPMyJid"];
    NSString *myPasswordUserDef = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCYXMPPMyPassword"];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 7, 290, 30)];
            usernameTextField.placeholder = @"请输入用户名";
            usernameTextField.borderStyle = UITextBorderStyleNone;
            usernameTextField.clearButtonMode = UITextFieldViewModeAlways;
            usernameTextField.keyboardType = UIKeyboardTypeASCIICapable;
            usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            usernameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            usernameTextField.delegate = self;
            usernameTextField.returnKeyType = UIReturnKeyNext;
            usernameTextField.text = myJidUserDef;
            [cell.contentView addSubview:usernameTextField];
        }
        else if(indexPath.row == 1)
        {
            passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 7, 290, 30)];
            passwordTextField.placeholder = @"请输入密码";
            passwordTextField.borderStyle = UITextBorderStyleNone;
            passwordTextField.clearButtonMode = UITextFieldViewModeAlways;
            passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;
            passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            passwordTextField.secureTextEntry = TRUE;
            passwordTextField.delegate = self;
            passwordTextField.returnKeyType = UIReturnKeyGo;
            passwordTextField.text = myPasswordUserDef;
            [cell.contentView addSubview:passwordTextField];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"登录";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
        else
        {
            cell.textLabel.text = @"注册";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            
            if ([usernameTextField.text length] && [passwordTextField.text length]) {
                
                [self login:nil];
//                if ([[AppKeFuIMSDK sharedInstance] isConnected]) {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                                    message:@"已经登录,无需重复登录"
//                                                                   delegate:nil
//                                                          cancelButtonTitle:@"确定"
//                                                          otherButtonTitles: nil];
//                    [alert show];
//                    return;
//                }
                //登录
//                [[AppKeFuIMSDK sharedInstance] loginWithUsername:usernameTextField.text
//                                                        password:passwordTextField.text
//                                                          inView:self.view];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名或密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            
            [self.view endEditing:YES];
            
        }
        else
        {
            [WTStatusBar setStatusText:@"Hello World!" timeout:2.0 animated:YES];
//            RegisterViewController *registerVC = [[RegisterViewController alloc] initWithStyle:UITableViewStyleGrouped];
//            [self.navigationController pushViewController:registerVC animated:YES];
        }
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == usernameTextField) {
        [passwordTextField becomeFirstResponder];
    }
    
    if (textField == passwordTextField) {
        [passwordTextField resignFirstResponder];
        
        if ([usernameTextField.text length] && [passwordTextField.text length]) {
            
            [self login:nil];
//            if ([[AppKeFuIMSDK sharedInstance] isConnected]) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已经登录,无需重复登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//                [alert show];
//                return FALSE;
//            }
//            
//            //登录
//            [[AppKeFuIMSDK sharedInstance] loginWithUsername:usernameTextField.text password:passwordTextField.text inView:self.view];
            
        }
    }
    
    return YES;
}


#pragma mark Private

- (void)setField:(UITextField *)field forKey:(NSString *)key
{
    if (field.text != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:field.text forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Actions

- (void)login:(id)sender
{
    [self setField:usernameTextField forKey:@"kCYXMPPMyJid"];
    [self setField:passwordTextField forKey:@"kCYXMPPMyPassword"];
    [[self appDelegate]connect];
    
    RosterViewController *controller=[[RosterViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
