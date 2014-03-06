//
//  MessagesViewController.m
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

#import "MessagesViewController.h"
#import "MessageInputView.h"
#import "NSString+MessagesView.h"
#import "UIView+AnimationOptionsForCurve.h"
#import "ChatClass.h"
#import "ChatCell.h"

#define INPUT_HEIGHT 46.0f

@interface MessagesViewController ()
{
    BOOL isVoiceAvailable;
    
    UIView *moreFunctionView;//更多功能
    
    UIView *faceView;
    UIScrollView *faceScrollView;
    StyledPageControl *SPageControl;
}

- (void)setup;

@end

@implementation MessagesViewController

@synthesize isLongPressOnCell;
@synthesize isSendingMsg;
@synthesize inputView=_inputView;
@synthesize tableView=_tableView;

#pragma mark - Initialization
- (void)setup
{
    CGSize size = self.view.frame.size;
	
    CGRect tableFrame = CGRectMake(0.0f, 0, size.width, size.height - INPUT_HEIGHT);
	self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];
	
    UIColor *color = [UIColor colorWithRed:240.0/255.0f green:240.0/255.0f blue:240.0/255.0f alpha:1.0f];
    [self setBackgroundColor:color];
    
    [self setUpInputView];
    
    //更多操作界面
    [self initWithMoreFunctionView];
}

-(void)setUpInputView
{
    CGSize size = self.view.frame.size;
    CGRect inputFrame = CGRectMake(0.0f, size.height - INPUT_HEIGHT, size.width, INPUT_HEIGHT);
    if (!self.inputView) {
        self.inputView = [[MessageInputView alloc] initWithFrame:inputFrame];
    }
    
    self.inputView.textView.delegate = self;
    
    [self.view addSubview:self.inputView];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    swipe.numberOfTouchesRequired = 1;
    [self.inputView addGestureRecognizer:swipe];
    
    //添加长按手势
    [self.inputView.pressButton addTarget:self action:@selector(buttonTouchBegin:) forControlEvents:UIControlEventTouchDown];
    [self.inputView.pressButton addTarget:self action:@selector(buttonTouchEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputView.pressButton addTarget:self action:@selector(buttonTouchEnd:) forControlEvents:UIControlEventTouchUpOutside];
    
    [self.inputView.plusButton addTarget:self action:@selector(plusAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputView.emojiButton addTarget:self action:@selector(emojiAction:) forControlEvents:UIControlEventTouchUpInside];
    //
    [self.inputView.voiceButton addTarget:self action:@selector(showHideTextField) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark 更多功能
-(void)initWithMoreFunctionView
{
    moreFunctionView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 184.0)];
    moreFunctionView.backgroundColor=[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    
    NSArray *buttonNameArr=[NSArray arrayWithObjects:@"照片",@"拍摄",@"产品",@"快捷回复",@"邀请评论", nil];
    NSArray *buttonImgArr=[NSArray arrayWithObjects:@"photo_chat.png",@"camera_chat.png",@"peoduct_chat.png",@"quickReply_chat.png",@"end_chat.png", nil];
    
    float button_x=26.0;
    float button_y=10.0;
    for (int j=0; j<2; j++) {
        for (int i=0; i<4; i++) {
            int index=j*4+i;
            if (index>=[buttonImgArr count]) {
                break;
            }
            UIButton *functionButton=[UIButton buttonWithType:UIButtonTypeCustom];
            functionButton.frame=CGRectMake(button_x, button_y, 52.0, 52.0);
            [functionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[buttonImgArr objectAtIndex:index]]] forState:UIControlStateNormal];
            functionButton.tag=index;
            [functionButton addTarget:self action:@selector(functionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [moreFunctionView addSubview:functionButton];
            
            UILabel *functionNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(button_x, CGRectGetMaxY(functionButton.frame)+5.0, 52.0, 20.0)];
            functionNameLabel.backgroundColor=[UIColor clearColor];
            functionNameLabel.text=[buttonNameArr objectAtIndex:index];
            functionNameLabel.font=[UIFont systemFontOfSize:14.0];
            functionNameLabel.textAlignment=UITextAlignmentCenter;
            functionNameLabel.adjustsFontSizeToFitWidth=YES;
            functionNameLabel.textColor=[UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1.0];
            [moreFunctionView addSubview:functionNameLabel];
            
            button_x+=72.0;
        }
        button_x=26.0;
        button_y+=87.0;
    }
    
}

#pragma mark toolBarButtonAction
-(void)showHideTextField
{
    self.inputView.emojiButton.tag=0;
    [self.inputView.emojiButton setImage:[UIImage imageNamed:@"qa_exp.png"] forState:UIControlStateNormal];
    if(isVoiceAvailable)
    {
        [self.inputView.voiceButton setImage:[UIImage imageNamed:@"qa_voice.png"] forState:UIControlStateNormal];
        [self.inputView.pressButton setHidden:YES];
        [self.inputView.inputFieldBg setHidden:NO];
        [self.inputView.textView setHidden:NO];
        [self.inputView.textView becomeFirstResponder];
        isVoiceAvailable=NO;
    }
    else
    {
        [self.inputView.voiceButton setImage:[UIImage imageNamed:@"qa_s.png"] forState:UIControlStateNormal];
        [self.inputView.pressButton setHidden:NO];
        [self.inputView.inputFieldBg setHidden:YES];
        [self.inputView.textView setHidden:YES];
        [self.inputView.textView resignFirstResponder];
        isVoiceAvailable=YES;
    }
    self.inputView.textView.inputView=nil;
    [self.inputView.textView reloadInputViews];
}
-(void)emojiAction:(UIButton *)sender
{
    sender.tag=!sender.tag;
	if (sender.tag||self.inputView.textView.inputView==nil) {
        [self.inputView.emojiButton setImage:[UIImage imageNamed:@"qa_s.png"] forState:UIControlStateNormal];
        
        if (!faceView) {
            faceView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 216.0)];
            faceView.backgroundColor=[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
            
            faceScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 5.0, SCREEN_WIDTH, 162.0)];
            faceScrollView.backgroundColor=[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
            faceScrollView.delegate=self;
            for (int i=0; i<5; i++) {
                FacialView *fview=[[FacialView alloc] initWithFrame:CGRectMake(10.0+SCREEN_WIDTH*i, 1.0, SCREEN_WIDTH-20.0, 216.0)];
                [fview loadFacialView:i size:CGSizeMake((SCREEN_WIDTH-20.0)/7.0, 40)];
                fview.delegate=self;
                [faceScrollView addSubview:fview];
            }
            faceScrollView.showsHorizontalScrollIndicator=NO;
            faceScrollView.contentSize=CGSizeMake(SCREEN_WIDTH*5, 162.0);
            faceScrollView.pagingEnabled=YES;
            [faceView addSubview:faceScrollView];
            
            SPageControl=[[StyledPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(faceScrollView.frame), SCREEN_WIDTH, 15.0)];
            SPageControl.backgroundColor=[UIColor clearColor];
            [SPageControl setPageControlStyle:PageControlStyle_hehun];
            SPageControl.selectedThumbImage=[UIImage imageNamed:@"dot1.png"];
            SPageControl.thumbImage=[UIImage imageNamed:@"dot3.png"];
            SPageControl.numberOfPages = 5;
            [SPageControl setCurrentPage: 0];
            SPageControl.userInteractionEnabled=NO;
            [faceView addSubview:SPageControl];
            
            UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, 216.0-36.0, SCREEN_WIDTH, 1.0)];
            line.backgroundColor=[UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0];
            [faceView addSubview:line];
            
            UIButton *faceSendButton=[UIButton buttonWithType:UIButtonTypeCustom];
            faceSendButton.frame=CGRectMake(0, 216.0-35.0, SCREEN_WIDTH, 35.0);
            [faceSendButton setTitle:@"发送" forState:UIControlStateNormal];
            [faceSendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [faceSendButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
            [faceSendButton addTarget:self action:@selector(faceSendAction) forControlEvents:UIControlEventTouchUpInside];
            [faceView addSubview:faceSendButton];
        }
        
		self.inputView.textView.inputView=faceView;
        [self.inputView.textView reloadInputViews];
		[self.inputView.textView becomeFirstResponder];
        sender.tag=1;
	}else {
        [self.inputView.emojiButton setImage:[UIImage imageNamed:@"qa_exp.png"] forState:UIControlStateNormal];
		self.inputView.textView.inputView=nil;
		[self.inputView.textView reloadInputViews];
		[self.inputView.textView becomeFirstResponder];
        sender.tag=0;
	}
    
    [self.inputView.voiceButton setImage:[UIImage imageNamed:@"qa_voice.png"] forState:UIControlStateNormal];
    [self.inputView.pressButton setHidden:YES];
    [self.inputView.inputFieldBg setHidden:NO];
    [self.inputView.textView setHidden:NO];
    isVoiceAvailable=NO;
}

-(void)plusAction:(UIButton*)sender
{
    sender.tag=!sender.tag;
	if (sender.tag||self.inputView.textView.inputView==nil) {
		self.inputView.textView.inputView=moreFunctionView;
        [self.inputView.textView reloadInputViews];
        [self.inputView.textView becomeFirstResponder];
        sender.tag=1;
	}else {
		self.inputView.textView.inputView=nil;
        [self.inputView.textView reloadInputViews];
        [self.inputView.textView becomeFirstResponder];
        sender.tag=0;
	}
}

-(void)faceSendAction
{
    [self sendPressed:nil];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    isVoiceAvailable=NO;
    
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tableView.dataSource = self;
	self.tableView.delegate = self;
    
    [self scrollToBottomAnimated:NO];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillShowKeyboard:)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillHideKeyboard:)
												 name:UIKeyboardWillHideNotification
                                              object:nil];
     
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

/*
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"*** %@: didReceiveMemoryWarning ***", self.class);
}
 */

#pragma mark - View rotation
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.tableView reloadData];
    [self.tableView setNeedsLayout];
}

#pragma mark - Actions
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text { } // override in subclass

- (void)sendPressed:(UIButton *)sender
{
    [self sendPressed:sender
             withText:[self.inputView.textView.text trimWhitespace]];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        //[textView resignFirstResponder];
        if (!isSendingMsg) {
            isSendingMsg=YES;
            [self sendPressed:nil];
        }
        
        return NO;
    }else {
        isSendingMsg=NO;
    }
    return YES;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView==self.tableView) {
        [self.inputView.textView resignFirstResponder];
    }
    
}

- (void)handleSwipe:(UIGestureRecognizer *)guestureRecognizer
{
    [self.inputView.textView resignFirstResponder];
}

#pragma mark FacialViewDelegate
-(void)selectedFacialView:(NSString *)str
{
    NSString *faceName=[NSString stringWithFormat:@"%@",[QQ_FACE_ARRAY objectAtIndex:[str intValue]]];
    if ([faceName compare:@"delete_face"]==0) {
        //删除
        NSString *currentText=self.inputView.textView.text;
        if (currentText.length>0) {
            self.inputView.textView.text=[currentText substringWithRange:NSMakeRange(0, currentText.length-1)];
            
            [self textViewDidChange:self.inputView.textView];
        }
    }else{
        self.inputView.textView.text=[NSString stringWithFormat:@"%@[%@]",self.inputView.textView.text,faceName];
        [self textViewDidChange:self.inputView.textView];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    BubbleMessageStyle style = [self messageStyleForRowAtIndexPath:indexPath];
    NSString *CellID = [NSString stringWithFormat:@"MessageCell%d", style];
    BubbleMessageCell *cell = (BubbleMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellID];
    if(!cell) {
        cell = [[BubbleMessageCell alloc] initWithBubbleStyle:style
                                              reuseIdentifier:CellID];
    }
    cell.bubbleView.date=[self dateForRowAtIndexPath:indexPath];
    cell.bubbleView.userImage=[self userImageForRowAtIndexPath:indexPath];
    if([self contentImageForRowAtIndexPath:indexPath])
    {
        cell.bubbleView.contentImage=[self contentImageForRowAtIndexPath:indexPath];
        cell.bubbleView.text =@"";
    }else{
        cell.bubbleView.contentImage=nil;
        cell.bubbleView.text = [self textForRowAtIndexPath:indexPath];
    }
    cell.backgroundColor = tableView.backgroundColor;
    return cell;
     */
    
    static NSString *cellIndentifier=@"ExpertChatcell";
    ChatCell *cell=(ChatCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell=[[ChatCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
        cell.backgroundColor=[UIColor clearColor];
        cell.accessoryType=UITableViewCellAccessoryNone;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    int contentType=[self contentTypeTimeForRowAtIndexPath:indexPath];
//    int contentType=0;
    
    float cellHeight=[self cellHeightForRowAtIndexPath:indexPath];
    UIView *tempView=[self cellContentViewForRowAtIndexPath:indexPath];
    
    BOOL showTime=NO;
    if (tempView.frame.size.height<30) {
        if ((cellHeight-54.0)>=20.0) {
            showTime=YES;
        }
    }else{
        if ((cellHeight-tempView.frame.size.height-30.0)>=20.0) {
            showTime=YES;
        }
    }
    cell.expertTime.text=[self contentSendTimeForRowAtIndexPath:indexPath];
    cell.expertTime.hidden=!showTime;
    
    if (contentType==0) {
        //专家
        cell.userIcon.image=[self userImageForRowAtIndexPath:indexPath];
        if (showTime) {
            cell.userIcon.frame=CGRectMake(SCREEN_WIDTH-47.0, 25.0, 40, 40);
        }else{
            cell.userIcon.frame=CGRectMake(SCREEN_WIDTH-47.0, 5.0, 40, 40);
        }
        cell.userIcon.layer.cornerRadius=5;
        cell.userIconButton.frame=cell.userIcon.frame;
        cell.userIconButton.userInteractionEnabled=NO;
        cell.userIconButton.tag=0;
        
        cell.contentBg.frame=CGRectMake(5.0, CGRectGetMinY(cell.userIcon.frame)+10.0, 42.0, 30.0);
        cell.contentBg.image=[UIImage imageNamed:@"messageBubbleBlue"];
        [cell.contentBg setContentStretch:CGRectMake(0.2f, 0.65f, 0.2, 0)];
        float contentWidth=tempView.frame.size.width+20.0<42.0?42.0:tempView.frame.size.width+20.0;
        CGRect frame = cell.contentBg.frame;
        frame.origin.x=SCREEN_WIDTH-contentWidth-55.0;
        frame.size.height= tempView.frame.size.height+12.0;//10.0
        frame.size.width=contentWidth;
        cell.contentBg.frame = frame;
        for (id qaObject in cell.qaContentView.subviews) {
            [qaObject removeFromSuperview];
        }
        [cell.qaContentView addSubview:tempView];
        cell.qaContentView.frame=CGRectMake(CGRectGetMinX(cell.contentBg.frame)+8.0, CGRectGetMinY(cell.contentBg.frame)+5.0, tempView.frame.size.width, tempView.frame.size.height);
        
    }else{
        //个人回答
        cell.userIcon.image=[self userImageForRowAtIndexPath:indexPath];
        
        if (showTime) {
            cell.userIcon.frame=CGRectMake(7.0, 25.0, 40, 40);
        }else{
            cell.userIcon.frame=CGRectMake(7.0, 5.0, 40, 40);
        }
        cell.userIcon.layer.cornerRadius=5;
        cell.userIconButton.frame=cell.userIcon.frame;
        cell.userIconButton.userInteractionEnabled=YES;
        cell.userIconButton.tag=1;
        [cell.userIconButton addTarget:self action:@selector(checkUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.contentBg.frame=CGRectMake(55.0, CGRectGetMinY(cell.userIcon.frame)+10.0, 42.0, 30.0);
        cell.contentBg.image=[UIImage imageNamed:@"messageBubbleGray"];
        [cell.contentBg setContentStretch:CGRectMake(0.5f, 0.65f, 0.2, 0)];
        CGRect frame = cell.contentBg.frame;
        frame.origin.x=55.0;
        frame.size.height= tempView.frame.size.height+12.0;//10.0
        frame.size.width=tempView.frame.size.width+20.0<42.0?42.0:tempView.frame.size.width+20.0;
        cell.contentBg.frame = frame;
        
        for (id qaObject in cell.qaContentView.subviews) {
            [qaObject removeFromSuperview];
        }
        [cell.qaContentView addSubview:tempView];
        cell.qaContentView.frame=CGRectMake(CGRectGetMinX(cell.contentBg.frame)+12.5, CGRectGetMinY(cell.contentBg.frame)+5.0, tempView.frame.size.width, tempView.frame.size.height);
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellHeightForRowAtIndexPath:indexPath];
}


#pragma mark - Messages view controller
- (BubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0; // Override in subclass
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil; // Override in subclass
}

- (void)finishSend
{
    isSendingMsg=NO;
    self.inputView.textView.text=@"";
    [self textViewDidChange:self.inputView.textView];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}

- (void)setBackgroundColor:(UIColor *)color
{
    self.view.backgroundColor = color;
    self.tableView.backgroundColor = color;
    self.tableView.separatorColor = color;
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    
    if(rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

#pragma mark - Text view delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView==self.inputView.textView) {
        [textView becomeFirstResponder];
        
        if(!self.previousTextViewContentHeight)
            self.previousTextViewContentHeight = textView.contentSize.height;
        
        [self scrollToBottomAnimated:YES];
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView==self.inputView.textView) {
        //[textView resignFirstResponder];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView==self.inputView.textView) {
        CGFloat maxHeight = [MessageInputView maxHeight];
        CGFloat textViewContentHeight = textView.contentSize.height;
        if ([textView.text compare:@""]==0) {
            textViewContentHeight=36.0;
        }
        CGFloat changeInHeight = textViewContentHeight - self.previousTextViewContentHeight;
        
        changeInHeight = (textViewContentHeight + changeInHeight >= maxHeight) ? 0.0f : changeInHeight;
        
        if(changeInHeight != 0.0f) {
            [UIView animateWithDuration:0.25f
                             animations:^{
                                 UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, self.tableView.contentInset.bottom + changeInHeight, 0.0f);
                                 self.tableView.contentInset = insets;
                                 self.tableView.scrollIndicatorInsets = insets;
                                 
                                 [self scrollToBottomAnimated:NO];
                                 
                                 CGRect inputViewFrame = self.inputView.frame;
                                 self.inputView.frame = CGRectMake(0.0f,
                                                                   inputViewFrame.origin.y - changeInHeight,
                                                                   inputViewFrame.size.width,
                                                                   inputViewFrame.size.height + changeInHeight);
                             }
                             completion:^(BOOL finished) {
                             }];
            
            self.previousTextViewContentHeight = MIN(textViewContentHeight, maxHeight);
        }
        
        self.inputView.sendButton.enabled = ([textView.text trimWhitespace].length > 0);
    }
}

#pragma mark UIScrollView
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView==self.tableView) {
        
//        if (scrollView.contentOffset.y<=0) {
//            [self getMoreMessageData];
//        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if (scrollView==self.tableView) {
//        if (scrollView.contentOffset.y<=10) {
//            [self showLoadMoreDataTipsView:YES];
//        }else{
//            [self showLoadMoreDataTipsView:NO];
//        }
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==faceScrollView) {
        float x_t = scrollView.contentOffset.x;
        float pageIndex=(x_t/(faceView.frame.size.width));
        SPageControl.currentPage=pageIndex;
    }
}

#pragma mark - Keyboard notifications
- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    if (isLongPressOnCell) {
        return;
    }
    [self keyboardWillShowHide:notification];
}

- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    if (isLongPressOnCell) {
        return;
    }
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:[UIView animationOptionsForCurve:curve]
                     animations:^{
                         
                         CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
                         
                         CGFloat ios7Top=0;
                         if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                             ios7Top=20;
                         }
                         
                         CGRect inputViewFrame = self.inputView.frame;
                         self.inputView.frame = CGRectMake(inputViewFrame.origin.x,
                                                           keyboardY - inputViewFrame.size.height -ios7Top,
                                                           inputViewFrame.size.width,
                                                           inputViewFrame.size.height);
                         
                         UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,
                                                                0.0f,
                                                                self.view.frame.size.height - self.inputView.frame.origin.y - INPUT_HEIGHT,
                                                                0.0f);
                         
                         self.tableView.contentInset = insets;
                         self.tableView.scrollIndicatorInsets = insets;
                     }
                     completion:^(BOOL finished) {
                     }];
}


@end