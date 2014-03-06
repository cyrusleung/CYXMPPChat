//
//  MessageObject.h
//  CYXMPPChat
//
//  Created by FatKa Leung on 14-2-23.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageObject : NSObject
@property (nonatomic,retain) NSString *messageFrom;
@property (nonatomic,retain) NSString *messageTo;
@property (nonatomic,retain) NSString *messageContent;
@property (nonatomic,retain) NSDate *messageDate;
@property (nonatomic,retain) NSNumber *messageType;
@end
