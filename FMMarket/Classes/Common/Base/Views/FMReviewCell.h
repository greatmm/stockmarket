//
//  FMReviewCell.h
//  FMMarket
//
//  Created by dangfm on 15/12/17.
//  Copyright © 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <M80AttributedLabel/M80AttributedLabel.h>

#define kFMInteractionCellHeight 50
#define kFMInteractionFaceWidth 40
#define kFMInteractionBottomHeight 50
#define kFMInteractionMargin 10
#define kFMInteractionPadding 10
#define kFMInteractionContentFontSize 14
#define kFMInteractionContentLineSpace 3
#define kFMInteractionContentWidth (UIScreenWidth - 2*kFMInteractionPadding-kFMInteractionFaceWidth-10)

@class FMReviewModel;

@interface FMReviewCell : UITableViewCell
<M80AttributedLabelDelegate>
{
    
}

@property (nonatomic,retain) UILabel * user_name;          // 用户名
@property (nonatomic,retain) UILabel * ask_time;           // 提问时间
@property (nonatomic,retain) UILabel * teacher_name;       // 投顾
@property (nonatomic,retain) M80AttributedLabel * answer;  // 回答内容
@property (nonatomic,retain) UILabel * user_id;            // 用户ID
@property (nonatomic,retain) UILabel * answer_time;        // 回答时间
@property (nonatomic,retain) UIImageView * user_face;      // 用户头像
@property (nonatomic,retain) M80AttributedLabel * ask;     // 问答内容
@property (nonatomic,retain) UIButton * askButton;         // 提问图标
@property (nonatomic,retain) UIButton * like;              // 点赞图标
@property (nonatomic,retain) UIView *answerBox;            // 回答区域
@property (nonatomic,retain) UIView *line;                 // 线条
@property (nonatomic,retain) FMReviewModel *model;
// 设置内容
-(void)setContents:(FMReviewModel*)model;
// 获取内容高度
+(float)heightWithModel:(FMReviewModel*)model;
@end


@interface FMReviewModel : NSObject

@property (nonatomic,retain) NSString * postId;             // 评论ID
@property (nonatomic,retain) NSString * nickName;           // 用户名
@property (nonatomic,retain) NSString * createTime;         // 提问时间
@property (nonatomic,retain) NSString * userFace;           // 用户头像
@property (nonatomic,retain) NSString * userId;             // 用户ID
@property (nonatomic,retain) NSString * device;             // 设备名称
@property (nonatomic,retain) NSString * parentId;           // 评论id
@property (nonatomic,retain) NSString * objectId;           // 评论对象ID
@property (nonatomic,retain) NSString * content;            // 内容
@property (nonatomic,assign) float height;                  // 高度
@property (nonatomic,retain) NSString *isLike;              // 是否点赞
@property (nonatomic,retain) NSString *likeCount;           // 点赞总数
@property (nonatomic,retain) NSString * replyNickName;      // 回复的用户名称
@property (nonatomic,retain) NSString * replyUserId;        // 回复的用户ID
// 初始化模型
-(instancetype)initWithDic:(NSDictionary *)dic;

@end

