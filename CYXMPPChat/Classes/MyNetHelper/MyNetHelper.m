//
//  MyNetHelper.m
//  Car
//
//  Created by MagicStudio on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyNetHelper.h"
#import "Reachability.h"

//#import <sys/socket.h>
//#import <netinet/in.h>
//#import <arpa/inet.h>
//#import <netdb.h>
//#import <SystemConfiguration/SCNetworkReachability.h>

@implementation MyNetHelper

+(BOOL)connectedToNetwork{
    BOOL isExistenceNetwork;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork=NO;
            break;
        case ReachableViaWWAN:
            isExistenceNetwork=YES;
            break;
        case ReachableViaWiFi:
            isExistenceNetwork=YES;
            break;
    }
    if (!isExistenceNetwork) {
        return NO;
    }else{
        return YES;
    }
}

@end
