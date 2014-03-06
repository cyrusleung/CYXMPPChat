//
//  FacialView.m
//  KeyBoardTest
//
//  Created by wangqiulei on 11-8-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacialView.h"
#import "SCGIFImageView.h"
#import "ChatClass.h"

@implementation FacialView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		//[self addSubview:loadFacial];
    } 
    return self;
}

//表情键盘绘制
-(void)loadFacialView:(int)page size:(CGSize)size
{
	//row number
	for (int i=0; i<4; i++) {
		//column numer
		for (int y=0; y<7.0; y++) {
            if (i*7.0+y+(page*28)<[QQ_FACE_ARRAY count]) {
                UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
                NSString *imgName=[NSString stringWithFormat:@"%@.png",[QQ_FACE_ARRAY objectAtIndex:i*7.0+y+(page*28)]];
                UIImageView* gifImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                gifImageView.frame=CGRectMake((size.width-28.0)/2.0+y*size.width, (size.height-28.0)/2.0+i*size.height, 28.0, 28.0);
                gifImageView.backgroundColor=[UIColor clearColor];
                
                [button setFrame:CGRectMake(0+y*size.width, 0+i*size.height, size.width, size.height)];
                button.tag=i*7.0+y+(page*28);
                [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:gifImageView];
                [self addSubview:button];
            }
		}
	}
}

//点击事件
-(void)selected:(UIButton*)bt
{
	NSString *str=[NSString stringWithFormat:@"%d",bt.tag];
	[delegate selectedFacialView:str];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/



@end
