//
//  ChatVoiceRecorderVC.h
//  Jeans
//
//  Created by Jeans on 3/23/13.
//  Copyright (c) 2013 Jeans. All rights reserved.
//

#import "VoiceRecorderBaseVC.h"


#define kRecorderViewRect       CGRectMake((SCREEN_WIDTH-120)/2, (SCREEN_HEIGHT-120)/2, 120, 120)
//#define kCancelOriginY          (kRecorderViewRect.origin.y + kRecorderViewRect.size.height + 180)
#define kCancelOriginY          ([[UIScreen mainScreen]bounds].size.height-70)

@interface ChatVoiceRecorderVC : VoiceRecorderBaseVC

//开始录音
-(void)endRecord;
- (void)beginRecordByFileName:(NSString*)_fileName;

@end
