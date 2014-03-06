//
//  UIImageView+Addition.m
//  PhotoLookTest
//
//  Created by waco on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define kCoverViewTag           1234
#define kImageViewTag           1235

#define kCoverViewTagNew           1000001
#define kImageViewTagNew           1000002
#define kAnimationDuration      0.3f
#define kImageViewWidth         300.0f
#define kBackViewColor          [UIColor colorWithWhite:0.667 alpha:0.5f]

#import "UIImageView+Addition.h"

@implementation UIImageView (UIImageViewEx)

- (void)hiddenView
{
    UIView *coverView = (UIView *)[self.superview.superview.superview.superview viewWithTag:kCoverViewTag];
    [coverView removeFromSuperview];
}

- (void)hiddenViewAnimation
{    
    UIImageView *imageView = (UIImageView *)[self.superview.superview.superview.superview viewWithTag:kImageViewTag];
    
    [UIView beginAnimations:nil context:nil];    
    [UIView setAnimationDuration:kAnimationDuration]; //动画时长
    CGRect rect = [self convertRect:self.bounds toView:self.superview.superview.superview.superview];
    imageView.frame = rect;
    
    [UIView commitAnimations];
    [self performSelector:@selector(hiddenView) withObject:nil afterDelay:kAnimationDuration];
    
}

//自动按原UIImageView等比例调整目标rect
- (CGRect)autoFitFrame
{
    //调整为固定宽，高等比例动态变化
    float width = kImageViewWidth;
    float targeHeight = (width*SCREEN_WIDTH)/SCREEN_HEIGHT;
    UIView *coverView = (UIView *)[self.superview.superview.superview.superview viewWithTag:kCoverViewTag];
    CGRect targeRect = CGRectMake(coverView.frame.size.width/2 - width/2, coverView.frame.size.height/2 - targeHeight/2, width, targeHeight);
    return targeRect;
}

- (void)imageTap
{    
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
    coverView.backgroundColor = kBackViewColor;
    coverView.tag = kCoverViewTag;
    UITapGestureRecognizer *hiddenViewGecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenViewAnimation)];
    [coverView addGestureRecognizer:hiddenViewGecognizer];
//    [hiddenViewGecognizer release];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.tag = kImageViewTag;
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = self.contentMode;
    CGRect rect = [self convertRect:self.bounds toView:self.superview.superview.superview.superview];
    imageView.frame = rect;
       
    [coverView addSubview:imageView];
    
    [self.superview.superview.superview.superview addSubview:coverView];
//    [coverView release];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kAnimationDuration];    
    imageView.frame = [self autoFitFrame]; 
    [UIView commitAnimations];
//    [imageView release];
}

- (void)addDetailShow
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)];
    [self addGestureRecognizer:tapGestureRecognizer];
//    [tapGestureRecognizer release];
}

-(void)addDetailShow:(UIView *)superView
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)];
    [self addGestureRecognizer:tapGestureRecognizer];
//    [tapGestureRecognizer release];
}

#pragma mark addDetailShow_ex

- (void)hiddenView_ex
{
    UIScrollView *coverView = (UIScrollView *)[self.superview.superview.superview.superview viewWithTag:kCoverViewTagNew];
    [coverView removeFromSuperview];
}

- (void)hiddenViewAnimation_ex
{
    UIImageView *imageView = (UIImageView *)[self.superview.superview.superview.superview viewWithTag:kImageViewTagNew];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kAnimationDuration]; //动画时长
    CGRect rect = [self convertRect:self.bounds toView:self.superview.superview.superview.superview];
    imageView.frame = rect;
    
    [UIView commitAnimations];
    [self performSelector:@selector(hiddenView_ex) withObject:nil afterDelay:kAnimationDuration];
    
}

//自动按原UIImageView等比例调整目标rect
- (CGRect)autoFitFrame_ex
{
    //调整为固定宽，高等比例动态变化
    float width = kImageViewWidth;
    float targeHeight = (width*self.frame.size.height)/self.frame.size.width;
    UIScrollView *coverView = (UIScrollView *)[self.superview.superview.superview.superview viewWithTag:kCoverViewTagNew];
    CGRect targeRect = CGRectMake(coverView.frame.size.width/2 - width/2, coverView.frame.size.height/2 - targeHeight/2, width, targeHeight);
    return targeRect;
}

-(void)imageTap_ex
{
    UIScrollView *coverScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH-30)];
    coverScrollView.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
    coverScrollView.tag=kCoverViewTagNew;
    [coverScrollView setDelegate:self];
    [coverScrollView setShowsHorizontalScrollIndicator:YES];
    [coverScrollView setShowsVerticalScrollIndicator:YES];
    [coverScrollView setMaximumZoomScale:3.0];
    
    UITapGestureRecognizer *hiddenViewGecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenViewAnimation_ex)];
    [coverScrollView addGestureRecognizer:hiddenViewGecognizer];
//    [hiddenViewGecognizer release];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.tag = kImageViewTagNew;
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = self.contentMode;
    CGRect rect = [self convertRect:self.bounds toView:self.superview.superview.superview.superview];
    imageView.frame = rect;

    [coverScrollView setContentSize:CGSizeMake([imageView frame].size.width+50, [imageView frame].size.height+100)];
    [coverScrollView setMinimumZoomScale:1.0];
    [coverScrollView setZoomScale:[coverScrollView minimumZoomScale]];
    [coverScrollView addSubview:imageView];
    [self.superview.superview.superview.superview addSubview:coverScrollView];
//    [coverScrollView release];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kAnimationDuration];
    imageView.frame = [self autoFitFrame_ex];
    [UIView commitAnimations];
//    [imageView release];
}

-(void)addDetailShow_ex
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer_ex = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap_ex)];
    [self addGestureRecognizer:tapGestureRecognizer_ex];
//    [tapGestureRecognizer_ex release];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIImageView *imageView = (UIImageView *)[[UIApplication sharedApplication].keyWindow viewWithTag:kImageViewTagNew];
    //CGRect rect = [self convertRect:self.bounds toView:self.superview.superview.superview.superview];
    CGRect frame=imageView.frame;
    frame.origin.x=(SCREEN_WIDTH-imageView.frame.size.width)/2.0>0?(SCREEN_WIDTH-imageView.frame.size.width)/2.0:0;
    frame.origin.y=(SCREEN_HEIGHT-imageView.frame.size.height-30)/2.0>0?(SCREEN_HEIGHT-imageView.frame.size.height-30)/2.0:0;
    imageView.frame=frame;
    return imageView;
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    UIImageView *imageView = (UIImageView *)[[UIApplication sharedApplication].keyWindow viewWithTag:kImageViewTagNew];
    //CGRect rect = [self convertRect:self.bounds toView:self.superview.superview.superview.superview];
    CGRect frame=imageView.frame;
    frame.origin.x=(SCREEN_WIDTH-imageView.frame.size.width)/2.0>0?(SCREEN_WIDTH-imageView.frame.size.width)/2.0:0;
    frame.origin.y=(SCREEN_HEIGHT-imageView.frame.size.height-30)/2.0>0?(SCREEN_HEIGHT-imageView.frame.size.height-30)/2.0:0;
    imageView.frame=frame;
    [scrollView setContentSize:CGSizeMake([imageView frame].size.width+50, [imageView frame].size.height+30)];
}

#pragma mark addDetailShow_chat

- (void)hiddenView_chat
{
    //self.superview.superview.superview.superview.superview.superview.superview.superview
    UIScrollView *coverView = (UIScrollView *)[[UIApplication sharedApplication].keyWindow viewWithTag:kCoverViewTagNew];
    [coverView removeFromSuperview];
}

- (void)hiddenViewAnimation_chat
{
    UIImageView *imageView = (UIImageView *)[[UIApplication sharedApplication].keyWindow viewWithTag:kImageViewTagNew];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kAnimationDuration]; //动画时长
    CGRect rect = [self convertRect:self.bounds toView:[UIApplication sharedApplication].keyWindow];
    imageView.frame = rect;
    
    [UIView commitAnimations];
    [self performSelector:@selector(hiddenView_chat) withObject:nil afterDelay:kAnimationDuration];
    
}

//自动按原UIImageView等比例调整目标rect
- (CGRect)autoFitFrame_chat
{
    //调整为固定宽，高等比例动态变化
    float width = kImageViewWidth;
    float targeHeight = (width*self.frame.size.height)/self.frame.size.width;
    UIScrollView *coverView = (UIScrollView *)[[UIApplication sharedApplication].keyWindow viewWithTag:kCoverViewTagNew];
    CGRect targeRect = CGRectMake(coverView.frame.size.width/2 - width/2, coverView.frame.size.height/2 - targeHeight/2, width, targeHeight);
    return targeRect;
}

-(void)imageTap_chat
{
    UIScrollView *coverScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    coverScrollView.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
    coverScrollView.tag=kCoverViewTagNew;
    [coverScrollView setDelegate:self];
    [coverScrollView setShowsHorizontalScrollIndicator:YES];
    [coverScrollView setShowsVerticalScrollIndicator:YES];
    [coverScrollView setMaximumZoomScale:3.0];
    
    UITapGestureRecognizer *hiddenViewGecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenViewAnimation_chat)];
    [coverScrollView addGestureRecognizer:hiddenViewGecognizer];
//    [hiddenViewGecognizer release];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.tag = kImageViewTagNew;
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = self.contentMode;
    CGRect rect = [self convertRect:self.bounds toView:[UIApplication sharedApplication].keyWindow];
    imageView.frame = rect;
    
    [coverScrollView setContentSize:CGSizeMake([imageView frame].size.width+50, [imageView frame].size.height+100)];
    [coverScrollView setMinimumZoomScale:1.0];
    [coverScrollView setZoomScale:[coverScrollView minimumZoomScale]];
    [coverScrollView addSubview:imageView];
    [[UIApplication sharedApplication].keyWindow addSubview:coverScrollView];
//    [coverScrollView release];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kAnimationDuration];
    imageView.frame = [self autoFitFrame_chat];
    [UIView commitAnimations];
//    [imageView release];
}

-(void)addDetailShow_chat
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer_chat = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap_chat)];
    [self addGestureRecognizer:tapGestureRecognizer_chat];
//    [tapGestureRecognizer_chat release];
}

@end