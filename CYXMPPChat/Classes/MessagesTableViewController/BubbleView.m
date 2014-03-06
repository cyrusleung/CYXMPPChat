//
//  BubbleView.m
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

#import "BubbleView.h"
#import "MessageInputView.h"
#import "NSString+MessagesView.h"
#import "Photo.h"

#define kMarginTop 8.0f+10.0f+5
#define kMarginBottom 4.0f+10
#define kPaddingTop 4.0f+4
#define kPaddingBottom 8.0f+2
#define kBubblePaddingRight 25.0f

@interface BubbleView()

@property (strong, nonatomic) UIImage *incomingBackground;
@property (strong, nonatomic) UIImage *outgoingBackground;

- (void)setup;

@end



@implementation BubbleView

@synthesize style;
@synthesize text;
@synthesize date;
@synthesize userImage;
@synthesize contentImage;

#pragma mark - Initialization
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.incomingBackground = [[UIImage imageNamed:@"messageBubbleGray"] stretchableImageWithLeftCapWidth:23 topCapHeight:20];
    self.outgoingBackground = [[UIImage imageNamed:@"messageBubbleBlue"] stretchableImageWithLeftCapWidth:15 topCapHeight:20];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
    }
    return self;
}

#pragma mark - Setters
- (void)setStyle:(BubbleMessageStyle)newStyle
{
    style = newStyle;
    [self setNeedsDisplay];
}

- (void)setDate:(NSString *)newDate
{
    date = newDate;
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)newText
{
    text = newText;
    [self setNeedsDisplay];
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)frame
{
	UIImage *image = (self.style == BubbleMessageStyleIncoming) ? self.incomingBackground : self.outgoingBackground;
    CGSize bubbleSize = [BubbleView bubbleSizeForText:self.text];
    if(self.contentImage)
    {
        bubbleSize=[BubbleView bubbleSizeForImage:self.contentImage];
    }
	CGRect bubbleFrame = CGRectMake(((self.style == BubbleMessageStyleOutgoing) ? self.frame.size.width - bubbleSize.width -50 : 50.0f),
                                    kMarginTop,
                                    bubbleSize.width,
                                    bubbleSize.height);
    
	[image drawInRect:bubbleFrame];
    
    if(self.style==BubbleMessageStyleIncoming)
    {
        [self.userImage drawInRect:CGRectMake(10, 23, 40, 40)];
    }
    else
    {
        [self.userImage drawInRect:CGRectMake(320-10-40, 23, 40, 40)];
    }
	
	
    
    if(self.contentImage)
    {
        [self.contentImage drawInRect:CGRectMake(((self.style == BubbleMessageStyleOutgoing) ? bubbleFrame.origin.x-2+11.5f : 50+4.0f+11.5f),
                                                 kPaddingTop + kMarginTop+0.5f,
                                                 self.contentImage.size.width,
                                                 self.contentImage.size.height)];
        
    }
    else
    {
        CGSize textSize = [BubbleView textSizeForText:self.text];
        CGFloat textX = (CGFloat)image.leftCapWidth - 3.0f + ((self.style == BubbleMessageStyleOutgoing) ? bubbleFrame.origin.x-2 : 50-5.0f);
        CGRect textFrame = CGRectMake(textX,
                                      kPaddingTop + kMarginTop,
                                      textSize.width,
                                      textSize.height);
        
        [self.text drawInRect:textFrame
                     withFont:[BubbleView font]
                lineBreakMode:NSLineBreakByWordWrapping
                    alignment:(self.style == BubbleMessageStyleOutgoing) ? NSTextAlignmentLeft : NSTextAlignmentLeft];
    }
    
    
    
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:1 green:0 blue:0 alpha:1].CGColor);
    
    UIImage *dateImage=[UIImage imageNamed:@"qa_dbg.png"];
    [dateImage drawInRect:CGRectMake((320.0-99.0)/2.0, 0, 99, 15)];
    //    UIImageView *dateImageView=[[UIImageView alloc] initWithFrame:CGRectMake((320.0-99.0)/2.0, 0, 99, 15)];
    //    [dateImageView setImage:[UIImage imageNamed:@"qa_dbg.png"]];
    //    [self addSubview:dateImageView];
    
    [[UIColor whiteColor] set];
    [self.date drawInRect:CGRectMake(0, 0, SCREEN_WIDTH, 20) withFont:[UIFont systemFontOfSize:11.f] lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];
    
    
    
    
    //画线
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor);
    //
    //    CGContextSetLineWidth(context, 1.0);
    //    CGContextMoveToPoint(context, 0, 8); //start at this point
    //    CGContextAddLineToPoint(context, (self.bounds.size.width - 120) / 2, 8); //draw to this point
    //
    //    CGContextMoveToPoint(context, self.bounds.size.width, 8); //start at this point
    //    CGContextAddLineToPoint(context, self.bounds.size.width - (self.bounds.size.width - 120) / 2, 8); //draw to this point
    //
    //    CGContextStrokePath(context);
    
}

#pragma mark - Bubble view
+ (UIFont *)font
{
    return [UIFont systemFontOfSize:16.0f];
}

+ (CGSize)textSizeForText:(NSString *)txt
{
    CGFloat width = [UIScreen mainScreen].applicationFrame.size.width * 0.65f;
    int numRows = (txt.length / [BubbleView maxCharactersPerLine]) + 1;
    
    CGFloat height = MAX(numRows, [txt numberOfLines]) * [MessageInputView textViewLineHeight];
    
    return [txt sizeWithFont:[BubbleView font]
           constrainedToSize:CGSizeMake(width, height)
               lineBreakMode:NSLineBreakByWordWrapping];
}

+ (CGSize)bubbleSizeForText:(NSString *)txt
{
	CGSize textSize = [BubbleView textSizeForText:txt];
	return CGSizeMake(textSize.width + kBubblePaddingRight,
                      textSize.height + kPaddingTop + kPaddingBottom);
}

+ (CGSize)bubbleSizeForImage:(UIImage *)image
{
	return CGSizeMake(image.size.width + kBubblePaddingRight,
                      image.size.height + kPaddingTop + kPaddingBottom);
}

+ (CGFloat)cellHeightForText:(NSString *)txt
{
    return [BubbleView bubbleSizeForText:txt].height + kMarginTop + kMarginBottom;
}

+ (CGFloat)cellHeightForImage:(UIImage *)image
{
    return [BubbleView bubbleSizeForImage:image].height + kMarginTop + kMarginBottom;
}

+ (int)maxCharactersPerLine
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 33 : 109;
}

@end