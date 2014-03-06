//
//  MyWebViewController.h
//  Car
//
//  Created by MagicStudio on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyWebViewController : UIViewController<UIWebViewDelegate,UIAlertViewDelegate>

@property (retain,nonatomic) NSString *urlStr;
@property (retain,nonatomic)  UIWebView *webView;

@property (nonatomic , retain)  UIView *opaqueView;
@property (nonatomic , retain)  UIActivityIndicatorView *indicatorView;

@end
