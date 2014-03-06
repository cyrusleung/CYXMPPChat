//
//  MyWebViewController.m
//  Car
//
//  Created by MagicStudio on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyWebViewController.h"

@implementation MyWebViewController
{
    UILabel *titleLabel;
}

@synthesize urlStr,webView=_webView,opaqueView,indicatorView;

#pragma mark - 开关等待对话框
-(void)showLoadingDialog{
    [self.opaqueView setHidden:NO];
    [self.indicatorView startAnimating];
}

-(void)dismissLoadingDialog{
    [self.opaqueView setHidden:YES];
    [self.indicatorView stopAnimating];
}

#pragma mark - 导航栏返回键点击
-(void)leftBtnPressed{
    if([self.webView canGoBack]){
        [self.webView goBack];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - 初始化导航栏按钮
-(void)initNavigationBar:(NSString *)title
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

    
    
    titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(45, 0, SCREEN_WIDTH-45*2, 44)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:title];
    [titleLabel setTextColor:[UIColor colorWithRed:120.0/255.0 green:58.0/255.0 blue:16.0/255.0 alpha:1.0]];
    [titleLabel setShadowColor:[UIColor colorWithRed:246.0/255.0 green:204.0/255.0 blue:141.0/255.0 alpha:1]];
    [titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    [self.view addSubview:titleLabel];
    
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


- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavigationBar:@"加载中"];
    
    _webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-44-20)];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    opaqueView=[[UIView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-44-20)];
    opaqueView.backgroundColor=[UIColor lightGrayColor];
    opaqueView.hidden=YES;
    [self.view addSubview:opaqueView];
    
    indicatorView=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-37.0)/2.0, (SCREEN_WIDTH-32-37.0)/2.0+50, 37, 37)];
    indicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhiteLarge;
    [opaqueView addSubview:indicatorView];
    [indicatorView startAnimating];
    

    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



#pragma UIWebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [self showLoadingDialog];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"加载失败。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
//    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    titleLabel.text=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    [self dismissLoadingDialog];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self leftBtnPressed];
}



@end
