//
//  MessageInputView.m
//
//  Created by Jesse Squires on 2/12/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//
//
//  Largely based on work by Sam Soffes
//  https://github.com/soffes
//
//  SSMessagesViewController
//  https://github.com/soffes/ssmessagesviewcontroller
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
//  following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "MessageInputView.h"
#import "BubbleView.h"

@interface MessageInputView ()

- (void)setup;
- (void)setupTextView;
- (void)setupVoiceButton;
- (void)setupSendButton;

@end

@implementation MessageInputView

@synthesize textView;
@synthesize inputFieldBg;
@synthesize voiceButton;
@synthesize pressButton;
@synthesize sendButton;
@synthesize emojiButton;
@synthesize plusButton;

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.image = [UIImage imageNamed:@"qa_bg.png"];
    self.backgroundColor = [UIColor colorWithRed:240.0/255.0f green:240.0/255.0f blue:240.0/255.0f alpha:1.0f];
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.userInteractionEnabled = YES;
    /*
    UIImageView *bgImg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qa_bg.png"]];
    bgImg.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:bgImg];
    [bgImg release];    
    */
    [self setupTextView];
    [self setupVoiceButton];
    [self setupEmojiButton];
    [self setupPlusButton];
    //    [self setupSendButton];
}

- (void)setupVoiceButton
{
    self.voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.voiceButton.frame = CGRectMake(7.0f, 8.0f, 30.0f, 30.0f);
    [self.voiceButton setImage:[UIImage imageNamed:@"qa_voice.png"] forState:UIControlStateNormal];
    [self addSubview:self.voiceButton];
    
    self.pressButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pressButton.frame = CGRectMake(44.0f, 8.0f, 195.0f, 32.0f);
    //    self.pressButton.adjustsImageWhenHighlighted = NO;
    //    self.pressButton.showsTouchWhenHighlighted = NO;
    [self.pressButton setImage:[UIImage imageNamed:@"qa_sbg.png"] forState:UIControlStateNormal];
    [self.pressButton setImage:[UIImage imageNamed:@"qa_sbg_hl.png"] forState:UIControlStateHighlighted];
    //    [self.pressButton setImage:[UIImage imageNamed:@"qa_sbg_hl.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
    [self.pressButton setImage:[UIImage imageNamed:@"qa_sbg_hl.png"] forState:UIControlStateSelected];
    
    [self addSubview:self.pressButton];
    
    [self.pressButton setHidden:YES];
    [self.inputFieldBg setHidden:NO];
    [self.textView setHidden:NO];
}

- (void)setupEmojiButton
{
    self.emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.emojiButton.tag=0;
    self.emojiButton.frame = CGRectMake(SCREEN_WIDTH-30- 7.0f-30-7.0f, 8.0f, 30.0f, 30.0f);
    [self.emojiButton setImage:[UIImage imageNamed:@"qa_exp.png"] forState:UIControlStateNormal];
    [self addSubview:self.emojiButton];
}

- (void)setupPlusButton
{
    self.plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.plusButton.frame = CGRectMake(SCREEN_WIDTH-30- 7.0f, 8.0f, 30.0f, 30.0f);
    self.plusButton.tag=0;
    [self.plusButton setImage:[UIImage imageNamed:@"qa_photo.png"] forState:UIControlStateNormal];
    [self addSubview:self.plusButton];
}

- (void)setupTextView
{
    CGFloat width = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 195.0f : 690.0f;
    CGFloat height = [MessageInputView textViewLineHeight] * [MessageInputView maxLines];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(44.0f, 5.0f, width, height)];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(13.0f, 0.0f, 14.0f, 7.0f);
    self.textView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 13.0f, 0.0f);
    self.textView.scrollEnabled = YES;
    self.textView.scrollsToTop = NO;
    self.textView.userInteractionEnabled = YES;
    self.textView.font = [BubbleView font];
    self.textView.textColor = [UIColor blackColor];
    self.textView.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.textView.keyboardType = UIKeyboardTypeDefault;
    self.textView.returnKeyType = UIReturnKeySend;
    [self addSubview:self.textView];
	
    self.inputFieldBg = [[UIImageView alloc] initWithFrame:CGRectMake(self.textView.frame.origin.x - 1.0f,
                                                                      0.0f,
                                                                      self.textView.frame.size.width + 2.0f,
                                                                      self.frame.size.height)];
    self.inputFieldBg.image = [[UIImage imageNamed:@"qa_ebg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 12.0f, 18.0f, 18.0f)];
    self.inputFieldBg.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self addSubview:self.inputFieldBg];
    
    [self bringSubviewToFront:self.textView];
}

- (void)setupSendButton
{
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.frame = CGRectMake(self.frame.size.width - 65.0f, 8.0f, 59.0f, 26.0f);
    self.sendButton.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f);
    UIImage *sendBack = [[UIImage imageNamed:@"send"] resizableImageWithCapInsets:insets];
    UIImage *sendBackHighLighted = [[UIImage imageNamed:@"send-highlighted"] resizableImageWithCapInsets:insets];
    [self.sendButton setBackgroundImage:sendBack forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:sendBack forState:UIControlStateDisabled];
    [self.sendButton setBackgroundImage:sendBackHighLighted forState:UIControlStateHighlighted];
    
    //    NSString *title = NSLocalizedString(@"Send", nil);
    NSString *title=@"发送";
    [self.sendButton setTitle:title forState:UIControlStateNormal];
    [self.sendButton setTitle:title forState:UIControlStateHighlighted];
    [self.sendButton setTitle:title forState:UIControlStateDisabled];
    self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    
    UIColor *titleShadow = [UIColor colorWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
    [self.sendButton setTitleShadowColor:titleShadow forState:UIControlStateNormal];
    [self.sendButton setTitleShadowColor:titleShadow forState:UIControlStateHighlighted];
    self.sendButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.sendButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateDisabled];
    
    self.sendButton.enabled = NO;
    [self addSubview:self.sendButton];
}

-(BOOL)canBecomeFirstResponder
{
    return NO;
}

#pragma mark - Message input view
+ (CGFloat)textViewLineHeight
{
    return 35.0f; // for fontSize 15.0f
}

+ (CGFloat)maxLines
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 4.0f : 8.0f;
}

+ (CGFloat)maxHeight
{
    return ([MessageInputView maxLines] + 1.0f) * [MessageInputView textViewLineHeight];
}



@end