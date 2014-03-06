//
//  UIImageView+Addition.h
//  PhotoLookTest
//
//  Created by waco on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImageView (UIImageViewEx)<UIScrollViewDelegate>

- (void)addDetailShow;

- (void)addDetailShow:(UIView *)superView;
-(void)addDetailShow_ex;
-(void)addDetailShow_chat;
@end
