//
//  XMPPMessageCoreDataStorageObject.h
//  CYXMPPChat
//
//  Created by FatKa Leung on 14-2-18.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XMPPMessageCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * messageFrom;
@property (nonatomic, retain) NSString * messageContent;
@property (nonatomic, retain) NSDate * messageDate;
@property (nonatomic, retain) NSNumber * messageType;
@property (nonatomic, retain) NSString * messageTo;

@end
