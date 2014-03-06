//
//  ChatClass.m
//  CYXMPPChat
//
//  Created by FatKa Leung on 14-2-16.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import "ChatClass.h"
#import "RTLabel.h"
#import "FileHelpers.h"
#import "ImageCacher.h"

@implementation ChatClass

#pragma mark 画表情到uiview上，
+(UIView *)assembleMessageAtIndex:(NSArray *)arr SuperClass:(id)superClass
{
#define KFacialSizeWidth 26
#define KFacialSizeHeight 26
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    returnView.backgroundColor=[UIColor clearColor];
    NSArray *data = arr;
    UIFont *fon=[UIFont systemFontOfSize:15.0f];
	CGFloat upX=0;
    CGFloat upY=0;
    
    CGFloat width=0;
    CGFloat cell_Width=SCREEN_WIDTH-83.0;
    
    //处理文字
    BOOL dealWithWord=YES;
    
	if (data) {
		for (int i=0;i<[data count];i++) {
			NSString *str=[data objectAtIndex:i];
            NSRange rangeBegin=[str rangeOfString:@"["];
            BOOL isFace=NO;
            if (rangeBegin.length>0&&(rangeBegin.location+1<str.length)) {
                NSString *tempStr=[str substringWithRange:NSMakeRange(rangeBegin.location+1,1)];
                if ([tempStr compare:@"["]!=0&&[tempStr compare:@"]"]!=0) {
                    isFace=YES;
                }
            }
            
			if ([str hasPrefix:@"["]&&[str hasSuffix:@"]"]&&isFace) //判断内容性质（图片以“/”开头），
            {
                if (upX > cell_Width||(upX+28.0) > cell_Width)
                {
                    upY = upY + KFacialSizeHeight;
                    width=cell_Width;
                    upX = 0;
                }
                /* 绘制gif表情 */
                NSString *str_temp=[str stringByReplacingOccurrencesOfString:@"[" withString:@""];
                str_temp=[str_temp stringByReplacingOccurrencesOfString:@"]" withString:@""];
                //NSArray *faceArray=[str componentsSeparatedByString:@"["];
                
                BOOL hasFace=NO;
                for (int q=0; q<[QQ_FACE_ARRAY count]; q++) {
                    NSString *qqFace=[NSString stringWithFormat:@"%@",[QQ_FACE_ARRAY objectAtIndex:q]];
                    if ([qqFace compare:str_temp]==0) {
                        hasFace=YES;
                        break;
                    }
                }
                if (hasFace) {
                    dealWithWord=NO;
                    UIImageView* gifImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",str_temp]]];
                    gifImageView.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                    gifImageView.backgroundColor=[UIColor clearColor];
                    [returnView addSubview:gifImageView];
                    
                    upX=KFacialSizeWidth+upX;
                    if (upX<=cell_Width&&width<upX) {
                        width=upX;
                    }
                }else{
                    //处理文字
                    dealWithWord=YES;
                }
			}else{
                //处理文字
                dealWithWord=YES;
            }
            
            if (dealWithWord) {
                //处理文字
                NSArray *strArrayWithUrl=[self checkTextWithUrl:str];
                for (int k=0; k<[strArrayWithUrl count]; k++) {
                    NSString *str_temp=[strArrayWithUrl objectAtIndex:k];
                    NSRange httpRange_temp=[str_temp rangeOfString:@"http://"];
                    NSRange httpsRange_temp=[str_temp rangeOfString:@"https://"];
                    NSRange ftpRange_temp=[str_temp rangeOfString:@"ftp://"];
                    NSRange wwwRange_temp=[str_temp rangeOfString:@"www."];
                    
                    
                    if (httpRange_temp.length>0||ftpRange_temp.length>0||httpsRange_temp.length>0||wwwRange_temp.length>0) {
                        
                        if (upX > cell_Width||(upX+14.0) > cell_Width)
                        {
                            upY = upY + KFacialSizeHeight;
                            upX = 0;
                            
                            width=cell_Width;
                        }
                        NSString *subString=str_temp;
                        CGSize size_f=[subString sizeWithFont:fon constrainedToSize:CGSizeMake(cell_Width, KFacialSizeHeight)];
                        if (size_f.width>(cell_Width-upX)) {
                            int strLoc=0;//截取字符游标
                            while (strLoc<str_temp.length) {
                                NSString *frontStr;
                                int subStrIndex=0;
                                int subStrLength=0;
                                while (subStrLength<(cell_Width-upX-5.0)) {
                                    if (subStrIndex<subString.length) {
                                        subStrIndex++;
                                        frontStr=[subString substringWithRange:NSMakeRange(0, subStrIndex)];
                                        CGSize size_temp=[frontStr sizeWithFont:fon constrainedToSize:CGSizeMake(cell_Width, KFacialSizeHeight)];
                                        subStrLength=size_temp.width;
                                    }else{
                                        break;
                                    }
                                    
                                }
                                //网址
                                frontStr=[frontStr stringByReplacingOccurrencesOfString:frontStr withString:[NSString stringWithFormat:@"<t type='%@'><font color=blue size=15><u color=blue>%@</u></font></t>",str_temp,frontStr]];
                                RTLabel *la=[[RTLabel alloc] initWithFrame:CGRectMake(upX, upY+1.0,cell_Width,KFacialSizeHeight-2.0)];
                                la.backgroundColor=[UIColor clearColor];
                                la.text=frontStr;
                                la.delegate=superClass;
                                la.frame=CGRectMake(upX, upY+1.0, cell_Width, la.optimumSize.height);
                                [returnView addSubview:la];
                                
                                subString=[subString substringWithRange:NSMakeRange(subStrIndex, subString.length-subStrIndex)];
                                strLoc+=subStrIndex;
                                upX+=la.frame.size.width;
                                
                                if (upX > cell_Width||(upX+14.0) > cell_Width)
                                {
                                    upY = upY + KFacialSizeHeight;
                                    upX = 0;
                                    
                                    width=cell_Width;
                                }
                                if (la.frame.size.height>24.0) {
                                    upY = upY + la.frame.size.height-24.0;
                                }
                            }
                        }else{
                            //网址
                            NSString *frontStr=subString;
                            frontStr=[frontStr stringByReplacingOccurrencesOfString:frontStr withString:[NSString stringWithFormat:@"<t type='%@'><font color=blue size=15><u color=blue>%@</u></font></t>",str_temp,frontStr]];
                            RTLabel *la=[[RTLabel alloc] initWithFrame:CGRectMake(upX, upY+1.0,cell_Width,24)];
                            la.backgroundColor=[UIColor clearColor];
                            la.text=frontStr;
                            la.delegate=superClass;
                            la.frame=CGRectMake(upX, la.frame.origin.y, la.frame.size.width, la.optimumSize.height);
                            [returnView addSubview:la];
                            
                            upX=upX+la.frame.size.width;
                            if (upX<=cell_Width&&width<upX) {
                                width=upX;
                            }
                            if (la.frame.size.height>24.0) {
                                upY = upY + la.frame.size.height-24.0;
                            }
                        }
                        
                        
                    }else{
                        for (int j = 0; j<[str_temp length]; j++)
                        {
                            NSString *temp = [str_temp substringWithRange:NSMakeRange(j, 1)];
                            
                            if ([temp compare:@"\n"]==0) {
                                upY = upY + KFacialSizeHeight;
                                upX = 0;
                                continue;
                            }
                            if (upX > cell_Width||(upX+14.0) >cell_Width)
                            {
                                upY = upY + KFacialSizeHeight;
                                upX = 0;
                                
                                width=cell_Width;
                            }
                            CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(cell_Width, KFacialSizeHeight)];
                            
                            UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX, upY+4.0,size.width,size.height)];
                            la.backgroundColor=[UIColor clearColor];
                            la.font = fon;
                            la.text = temp;
                            [returnView addSubview:la];
                            
                            upX=upX+size.width;
                            if (upX<=cell_Width&&width<upX) {
                                width=upX;
                            }
                        }
                    }
                }
            }
        }
	}
    returnView.frame=CGRectMake(0, 0, width, upY+24.0);
    return returnView;
}
#pragma mark 解释字符串(以“[]”表示表情)
+(NSArray *)parserMessage_new:(NSString*)message
{
    NSUInteger cnt = 0/* 表情符出现次数*/, length = [message length];/*字符长度*/
    NSRange range = NSMakeRange(0, length);
    NSMutableArray *targetStringArr=[[NSMutableArray alloc] init];
    while(range.location != NSNotFound)
    {
        range = [message rangeOfString: @"[" options:0 range:range];
        if(range.location != NSNotFound)
        {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            if (range.length>0) {
                NSString *tempStr=[message substringWithRange:NSMakeRange(range.location,1)];
                NSString *nextTempStr=@"";//下一个字符
                if (range.location+1<range.length) {
                    nextTempStr=[message substringWithRange:NSMakeRange(range.location+1,1)];
                }
                
                if ([tempStr compare:@"["]!=0&&[tempStr compare:@"]"]!=0) {
                    int existCount=0;
                    NSMutableArray *tempArray=[[NSMutableArray alloc] init];//表情临时数组
                    for (int i=0; i<[QQ_FACE_ARRAY count]; i++) {
                        NSRange faceRange=[[QQ_FACE_ARRAY objectAtIndex:i] rangeOfString:tempStr];
                        if (faceRange.location!=NSNotFound) {
                            [tempArray addObject:[NSString stringWithFormat:@"[%@]",[QQ_FACE_ARRAY objectAtIndex:i]]];
                            existCount++;
                        }
                    }
                    if ([nextTempStr compare:@"]"]==0&&[nextTempStr compare:@""]!=0) {
                        [targetStringArr addObject:[NSString stringWithFormat:@"[%@]",tempStr]];
                    }else{
                        if (existCount>1) {
                            int endLocation;
                            if (range.location+2<=message.length) {
                                endLocation=2;
                            }else{
                                endLocation=1;
                            }
                            NSString *tempFaceStr=[message substringWithRange:NSMakeRange(range.location,endLocation)];
                            for (int k=0; k<[tempArray count]; k++) {
                                NSString *faceString_temp=[tempArray objectAtIndex:k];
                                NSRange faceRange=[faceString_temp rangeOfString:tempFaceStr];
                                if (faceRange.location!=NSNotFound) {
                                    [targetStringArr addObject:[NSString stringWithFormat:@"%@",[tempArray objectAtIndex:k]]];
                                    break;
                                }
                            }
                        }else if(existCount==1){
                            [targetStringArr addObject:[tempArray objectAtIndex:0]];
                        }
                        cnt++;
                    }
                }
            }
        }
    }
    
    NSMutableArray *targetArray=[[NSMutableArray alloc] init];//解释结果数组
    NSString *strEnd=message;
    if ([targetStringArr count]>0) {
        for (int i=0; i<[targetStringArr count]; i++) {
            NSRange imageRange=[strEnd rangeOfString:[targetStringArr objectAtIndex:i]];
            if (imageRange.location!=NSNotFound) {
                
                int indexLocation=imageRange.location+[(NSString *)[targetStringArr objectAtIndex:i] length];
                NSString *firstString=[strEnd substringToIndex:indexLocation];
                NSString *endString=[strEnd substringFromIndex:indexLocation];
                
                //处理前端字符
                NSArray *array_temp=[firstString componentsSeparatedByString:[targetStringArr objectAtIndex:i]];
                if ([(NSString *)[array_temp objectAtIndex:0] length]>0) {
                    [targetArray addObject:[array_temp objectAtIndex:0]];
                    [targetArray addObject:[targetStringArr objectAtIndex:i]];
                }else{
                    [targetArray addObject:[targetStringArr objectAtIndex:i]];
                }
                
                
                //处理结束字符
                if ([endString length]>0) {
                    if (i+1<[targetStringArr count]) {
                        NSRange imageEndRange=[endString rangeOfString:[targetStringArr objectAtIndex:i+1]];
                        if (imageEndRange.location==NSNotFound) {
                            [targetArray addObject:endString];
                            break;
                        }else{
                            strEnd=endString;
                        }
                    }else{
                        [targetArray addObject:endString];
                        break;
                    }
                }
            }else{
                [targetArray addObject:strEnd];
                break;
            }
        }
    }else{
        [targetArray addObject:strEnd];
    }
    
    NSLog(@"targetArray:%@",targetArray);
    return targetArray;
}

#pragma mark 时间运算
+(NSString *)userTimeOperation:(NSString *)currentUserString OperationTime:(NSString *)operationTime
{
    NSArray *userStrArr = [currentUserString componentsSeparatedByString:@"|"];
    NSString *nameStr = [userStrArr objectAtIndex:0];
    NSString *sexStr = [userStrArr objectAtIndex:1];
    int year = ((NSString *)[userStrArr objectAtIndex:3]).intValue;
    int month = ((NSString *)[userStrArr objectAtIndex:4]).intValue;
    int day = ((NSString *)[userStrArr objectAtIndex:5]).intValue;
    NSString *riLiStr = [userStrArr objectAtIndex:2];
    
    NSString *birthStr = [NSString stringWithFormat:@"%d:%d:%d:%@:00:00",year,month,day,[userStrArr objectAtIndex:6]];
    
    NSDateFormatter *format_temp=[[NSDateFormatter alloc] init];
    [format_temp setDateFormat:@"yyyy:MM:dd:HH:mm:ss"];
    NSDate *currentDate=[format_temp dateFromString:birthStr];
    int timeApart=0;
    if ([operationTime rangeOfString:@"+"].length>0) {
        NSArray *timeArray_temp=[[operationTime stringByReplacingOccurrencesOfString:@"+" withString:@""] componentsSeparatedByString:@":"];
        timeApart=[[timeArray_temp objectAtIndex:0] intValue]*3600+[[timeArray_temp objectAtIndex:1] intValue]*60+[[timeArray_temp objectAtIndex:2] intValue];
    }else{
        NSArray *timeArray_temp=[[operationTime stringByReplacingOccurrencesOfString:@"-" withString:@""] componentsSeparatedByString:@":"];
        timeApart=0-[[timeArray_temp objectAtIndex:0] intValue]*3600-[[timeArray_temp objectAtIndex:1] intValue]*60-[[timeArray_temp objectAtIndex:2] intValue];
        
    }
    NSDate *newdate=[currentDate dateByAddingTimeInterval:timeApart];
    NSString *newTimeString=[format_temp stringFromDate:newdate];
    NSArray *newTimeArray=[newTimeString componentsSeparatedByString:@":"];
    
    NSString *newUserString=[NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@|%@|%@",nameStr,sexStr,riLiStr,[newTimeArray objectAtIndex:0],[newTimeArray objectAtIndex:1],[newTimeArray objectAtIndex:2],[newTimeArray objectAtIndex:3],[newTimeArray objectAtIndex:4],[userStrArr objectAtIndex:8]];
    return newUserString;
    
}

#pragma mark 字符串出现次数
+(int)stringAppearTimes:(NSString *)targetString AppearString:(NSString *)appearString
{
    NSUInteger cnt = 0, length = [targetString length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [targetString rangeOfString:appearString options:0 range:range];
        if(range.location != NSNotFound)
        {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            cnt++;
        }
    }
    return cnt;
}

#pragma mark 正则匹配网址(识别文本中是网址)
+(NSArray *)checkTextWithUrl:(NSString *)textString
{
    NSRange httpRange=[textString rangeOfString:@"http://"];
    NSRange httpsRange=[textString rangeOfString:@"https://"];
    NSRange ftpRange=[textString rangeOfString:@"ftp://"];
    NSRange wwwRange=[textString rangeOfString:@"www."];
    
    if (httpRange.length>0||ftpRange.length>0||httpsRange.length>0||wwwRange.length>0) {
        if (httpRange.length>0) {
            textString=[textString stringByReplacingOccurrencesOfString:@"http://" withString:@"---http://"];
        }
        if (ftpRange.length>0) {
            textString=[textString stringByReplacingOccurrencesOfString:@"ftp://" withString:@"---ftp://"];
        }
        if (httpsRange.length>0) {
            textString=[textString stringByReplacingOccurrencesOfString:@"https://" withString:@"---https://"];
        }
        if (wwwRange.length>0) {
            NSMutableString *targetTextString=[[NSMutableString alloc] initWithString:textString];
            int subLength=0;
            NSString *textString_copy=textString;
            int appearTimes=[self stringAppearTimes:textString AppearString:@"www."];
            for (int i=0; i<appearTimes; i++) {
                BOOL isUrl=NO;
                NSRange wwwPreRange=[textString_copy rangeOfString:@"www."];
                if (wwwRange.location==0) {
                    isUrl=YES;
                }else{
                    NSString *wwwPreString=[textString_copy substringWithRange:NSMakeRange(wwwPreRange.location-2, 2)];
                    if ([wwwPreString compare:@"//"]!=0) {
                        isUrl=YES;
                    }
                }
                if (isUrl) {
                    [targetTextString insertString:@"---" atIndex:subLength+wwwPreRange.location];
                }
                textString_copy=[textString_copy substringWithRange:NSMakeRange(wwwPreRange.location+4, textString_copy.length-wwwPreRange.location-4)];
                subLength+=wwwPreRange.location+4;
                if (isUrl) {
                    subLength+=3;
                }
            }
            textString=[NSString stringWithFormat:@"%@",targetTextString];
        }
        NSArray *textArray=[textString componentsSeparatedByString:@"---"];
        
        NSMutableArray *resultArray=[[NSMutableArray alloc] init];
        for (int i=0; i<[textArray count]; i++) {
            NSString *string_temp=[textArray objectAtIndex:i];
            NSRange httpRange_temp=[string_temp rangeOfString:@"http://"];
            NSRange httpsRange_temp=[string_temp rangeOfString:@"https://"];
            NSRange ftpRange_temp=[string_temp rangeOfString:@"ftp://"];
            NSRange wwwRange_temp=[string_temp rangeOfString:@"www."];
            if (httpRange_temp.length>0||ftpRange_temp.length>0||httpsRange_temp.length>0||wwwRange_temp.length>0) {
                BOOL isUrl_temp=NO;
                for (int j=string_temp.length; j>=0; j--) {
                    NSString *subString_temp = [string_temp substringWithRange:NSMakeRange(0, j)];
                    if ([self validateUrl:subString_temp]) {
                        isUrl_temp=YES;
                        [resultArray addObject:subString_temp];
                        NSString *endString_temp=[string_temp substringWithRange:NSMakeRange(j, string_temp.length-j)];
                        if ([endString_temp compare:@""]!=0) {
                            [resultArray addObject:endString_temp];
                        }
                        break;
                    }
                }
                if (!isUrl_temp) {
                    if ([string_temp compare:@""]!=0) {
                        [resultArray addObject:string_temp];
                    }
                }
            }else{
                if ([string_temp compare:@""]!=0) {
                    [resultArray addObject:string_temp];
                }
            }
        }
        return resultArray;
    }else{
        return [NSArray arrayWithObjects:textString,nil];
    }
    return nil;
}

//网址（正则）
+(BOOL) validateUrl: (NSString *) candidate {
    
    //NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9]+\\.([A-Za-z]{2,4}||[A-Za-z]{2,4}\\.[A-Za-z]{2,4})";
    NSString *emailRegex = @"(^(http|https|ftp)://)?([a-zA-Z0-9\\.\\-]+(:[a-zA-Z0-9\\.&amp;%\\$\\-]+)*@)?((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|([a-zA-Z0-9\\-]+\\.)*[a-zA-Z0-9\\-]+\\.[a-zA-Z]{2,4})(:[0-9]+)?(/[^/][a-zA-Z0-9\\.\\,\?\'\\/\\+&amp;%\\$#\\=~_\\-@]*)*$";//不匹配sysrage.net
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

+(NSString *)setTimeDisplayType:(NSDate *) constDate
{
    //    NSString *strDate = @"2012-08-07 09:59:01";
    //    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    //    formater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    //    NSDate *constDate = [formater dateFromString:strDate];
    //    [formater release];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    comps = [calendar components:unitFlags fromDate:constDate toDate:now options:0];
    
    //    NSInteger months = [comps month];
    //    NSInteger days = [comps day];
    //    NSInteger hours = [comps hour];
    //    NSInteger mins = [comps minute];
    //NSInteger secs = [comps second];
    
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    dateForm.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    return [NSString stringWithFormat:@"%@",[dateForm stringFromDate:now]];
    
    //    if (months == 0)
    //    {
    //        if (days == 0)
    //        {
    //            if (hours == 0)
    //            {
    //                if (mins == 0)
    //                {
    //                    return @"刚刚";
    //                }
    //                else
    //                {
    //                    return [NSString stringWithFormat:@"%d分钟前",mins];
    //                }
    //            }
    //            else
    //            {
    //                return [NSString stringWithFormat:@"%d小时前",hours];
    //            }
    //        }
    //        else
    //        {
    //            return [NSString stringWithFormat:@"%@",[dateForm stringFromDate:now]];
    //
    //        }
    //    }
    //    else
    //    {
    //        return [NSString stringWithFormat:@"%@",[dateForm stringFromDate:now]];
    //    }
    //    [dateForm release];
    //    [comps release];
}

@end
