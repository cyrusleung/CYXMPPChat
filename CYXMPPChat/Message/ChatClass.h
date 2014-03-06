//
//  ChatClass.h
//  CYXMPPChat
//
//  Created by FatKa Leung on 14-2-16.
//  Copyright (c) 2014年 CYDESIGN. All rights reserved.
//

#import <Foundation/Foundation.h>

#define QQ_FACE_ARRAY [NSArray arrayWithObjects:@"微笑",@"撇嘴",@"色",@"发呆",@"得意",@"流泪",@"害羞",@"闭嘴",@"睡",@"大哭",@"尴尬",@"发怒",@"调皮",@"呲牙",@"惊讶",@"难过",@"酷",@"冷汗",@"抓狂",@"吐",@"偷笑",@"可爱",@"白眼",@"傲慢",@"饥饿",@"困",@"惊恐",@"delete_face",@"流汗",@"憨笑",@"大兵",@"奋斗",@"咒骂",@"疑问",@"嘘",@"晕",@"折磨",@"衰",@"骷髅",@"敲打",@"再见",@"擦汗",@"抠鼻",@"鼓掌",@"糗大了",@"坏笑",@"左哼哼",@"右哼哼",@"哈欠",@"鄙视",@"委屈",@"快哭了",@"阴险",@"亲亲",@"吓",@"delete_face",@"可怜",@"菜刀",@"西瓜",@"啤酒",@"篮球",@"乒乓",@"咖啡",@"饭",@"猪头",@"玫瑰",@"凋谢",@"示爱",@"爱心",@"心碎",@"蛋糕",@"闪电",@"炸弹",@"刀",@"足球",@"瓢虫",@"便便",@"月亮",@"太阳",@"礼物",@"拥抱",@"强",@"弱",@"delete_face",@"握手",@"胜利",@"抱拳",@"勾引",@"拳头",@"差劲",@"爱你",@"no",@"ok",@"爱情",@"飞吻",@"跳跳",@"发抖",@"怄火",@"转圈",@"磕头",@"回头",@"跳绳",@"挥手",@"激动",@"街舞",@"献吻",@"左太极",@"右太极",@"双喜",@"鞭炮",@"灯笼",@"delete_face",@"发财",@"K歌",@"购物",@"邮件",@"帅",@"喝彩",@"祈祷",@"爆筋",@"棒棒糖",@"喝奶",@"下面",@"香蕉",@"飞机",@"开车",@"左车头",@"车厢",@"右车头",@"多云",@"下雨",@"钞票",@"熊猫",@"灯泡",@"风车",@"闹钟",@"打伞",@"彩球",@"钻戒",@"delete_face",@"沙发",@"纸巾",@"药",@"手枪",@"青蛙",@"招财猫",@"delete_face",nil]

enum kWCMessageLodaType {
    kWCMessageTypeLoadAll = 0,
    kWCMessageTypeLoadLimit = 1
};

@interface ChatClass : NSObject

+(UIView *)assembleMessageAtIndex:(NSArray *)arr SuperClass:(id)superClass;
+(NSArray *)parserMessage_new:(NSString*)message;

+(NSString *)userTimeOperation:(NSString *)currentUserString OperationTime:(NSString *)operationTime;//时间运算

+(NSArray *)checkTextWithUrl:(NSString *)textString;
+(BOOL) validateUrl: (NSString *) candidate;//正则匹配网址

//add by cyrus
+(NSString *)setTimeDisplayType:(NSDate *) constDate;

@end
