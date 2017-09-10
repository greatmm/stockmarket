//
//  FMReviewCell.m
//  FMMarket
//
//  Created by dangfm on 15/12/17.
//  Copyright © 2015年 dangfm. All rights reserved.
//

#import "FMReviewCell.h"
#import <UIImageView+WebCache.h>

@implementation FMReviewModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self==[super init]) {
        [fn reflectDataFromOtherObject:dic WithTarget:self];
    }
    return self;
}

@end
@implementation FMReviewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self==[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createViews];
    }
    return self;
}

-(void)layoutSubviews{
    CGRect frame = _line.frame;
//    frame.size.height = 5;
    frame.origin.y = self.frame.size.height-frame.size.height;
    frame.origin.x = 0;
    frame.size.width = UIScreenWidth;
    
    _line.frame = frame;
    
    self.selectedBackgroundView.frame = self.bounds;
}

-(void)createViews{
    
    
    self.backgroundColor = [UIColor clearColor];
    UIView *selectView = [[UIView alloc] initWithFrame:self.bounds];
    selectView.backgroundColor = ThemeColor(@"UITableViewCell_SelectView_BackgroundColor");
    self.selectedBackgroundView = selectView;
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    self.contentView.layer.borderColor = FMBottomLineColor.CGColor;
//    self.contentView.layer.borderWidth = 0.5;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    float w = kFMInteractionContentWidth;
    float h = 15;
    float cw = 10;
    float x = kFMInteractionPadding + kFMInteractionFaceWidth;
    _user_face = [[UIImageView alloc] initWithImage:ThemeImage(@"me/me_icon_userface_normal")];
    _user_face.frame = CGRectMake(kFMInteractionPadding, kFMInteractionPadding, kFMInteractionFaceWidth, kFMInteractionFaceWidth);
    _user_face.layer.cornerRadius = kFMInteractionFaceWidth / 2;
    _user_face.layer.masksToBounds = YES;
    _user_name = [UILabel createWithTitle:@"" Frame:CGRectMake(x+10, _user_face.frame.origin.y, w, 20)];
    _user_name.textColor = FMZeroColor;
    _ask_time = [UILabel createWithTitle:@"" Frame:CGRectMake(_user_name.frame.origin.x,_user_name.frame.origin.y+_user_name.frame.size.height,_user_name.frame.size.width,_user_name.frame.size.height)];
    _ask_time.font = kFont(10);
    _ask_time.textColor = FMBlackColor;
    
    _ask = [[M80AttributedLabel alloc] initWithFrame:CGRectMake(x+10, _user_face.frame.origin.y+_user_face.frame.size.height+10, w, CGFLOAT_MAX)];
    // 文字间隙
//    _ask.characterSpacing = 2;
    _ask.underLineForLink = NO;
    // 文本行间隙
    _ask.lineSpacing = kFMInteractionContentLineSpace;
    _ask.font = kDefaultFont;
    _ask.delegate = self;
    _ask.backgroundColor = [UIColor clearColor];
    
    _answerBox = [[UIView alloc] initWithFrame:CGRectMake(_ask.frame.origin.x, _ask.frame.size.height+_ask.frame.origin.y, _ask.frame.size.width, _ask.frame.size.height)];
    _answerBox.layer.cornerRadius = 3;
    _answerBox.layer.masksToBounds = YES;
    _answerBox.backgroundColor = FMNoPhotoBgColor;
    
    [_answerBox addSubview:_teacher_name];
    
    float iconWidth = 40;
    UIImage *asgIcon = ThemeImage(@"global/icon_reply_normal");
//    asgIcon = [UIImage imageWithTintColor:FMBottomLineColor blendMode:kCGBlendModeDestinationIn WithImageObject:asgIcon];
    float iconHeight = asgIcon.size.height;
    _askButton = [UIButton createButtonWithTitle:@"" Frame:CGRectMake(UIScreenWidth-kFMInteractionPadding-iconWidth,kFMInteractionPadding, iconWidth, iconHeight)];
    [_askButton setImage:asgIcon forState:UIControlStateNormal];
    asgIcon = [UIImage imageWithTintColor:FMBlueColor blendMode:kCGBlendModeDestinationIn WithImageObject:asgIcon];
    [_askButton setImage:asgIcon forState:UIControlStateHighlighted];
    _askButton.layer.borderWidth = 0;
    
    UIImage *likeIcon = ThemeImage(@"global/icon_like_normal");
//    likeIcon = [UIImage imageWithTintColor:FMBottomLineColor blendMode:kCGBlendModeDestinationIn WithImageObject:likeIcon];
    _like = [UIButton createButtonWithTitle:@"" Frame:CGRectMake(UIScreenWidth-2*kFMInteractionPadding-2*iconWidth, kFMInteractionPadding, iconWidth, iconHeight)];
    [_like setImage:likeIcon forState:UIControlStateNormal];
    [_like setImage:[UIImage imageWithTintColor:FMBlueColor blendMode:kCGBlendModeDestinationIn WithImageObject:likeIcon] forState:UIControlStateHighlighted];
    _like.layer.borderWidth = 0;
    _like.titleLabel.font = kFont(10);
    _like.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_like addTarget:self action:@selector(clickLikeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    _line = [fn drawLineWithSuperView:self Color:FMBgGreyColor Location:1];
    
    [self.contentView addSubview:_user_name];
    [self.contentView addSubview:_user_face];
    [self.contentView addSubview:_ask_time];
    [self.contentView addSubview:_ask];
    [self.contentView addSubview:_like];
    [self.contentView addSubview:_askButton];
//    [self.contentView addSubview:_line];
}

-(void)setContents:(FMReviewModel *)model{
    _model = model;
    // 用户名
    _user_name.text = model.nickName;
    NSString *content = model.content;
    
    if ([model.replyUserId intValue]>0) {
        NSString *replyStr = [NSString stringWithFormat:@"回复@%@:",model.replyNickName];
        // 回复样式
        content = [replyStr stringByAppendingString:model.content];
    }
    [_ask setText:content];
    if ([model.replyUserId intValue]>0) {
        [_ask addCustomLink:model.replyUserId forRange:[content rangeOfString:[NSString stringWithFormat:@"@%@:",model.replyNickName]] linkColor:FMBlueColor];
    }
//    [_ask sizeToFit];
    
    
    NSString *ask_time = model.createTime;
    if (ask_time) {
        ask_time = [ask_time distanceNowTime];
    }
    _ask_time.text = [ask_time append:[NSString stringWithFormat:@" 来自%@",model.device]];
    // [_ask addLinkWithLinkData:@"http://www.baidu.com" range:[_ask.text rangeOfString:@"603993"]];
    
    CGRect frame = _user_name.frame;
    // 时间在名字下面
    frame.origin.y = _user_name.frame.size.height + _user_name.frame.origin.y;
    _ask_time.frame = frame;
    // 图标在时间右边
//    frame = _askButton.frame;
//    frame.origin.y = _ask_time.frame.origin.y;
//    _askButton.frame = frame;
    // 内容的位置
    CGSize size = [_ask sizeThatFits:CGSizeMake(kFMInteractionContentWidth, CGFLOAT_MAX)];
    frame = _ask.frame;
    frame.origin.y = _ask_time.frame.size.height + _ask_time.frame.origin.y+3;
    frame.size.height = size.height;
    _ask.frame = frame;

    
//    // 显示回复列表
//    NSArray *list = model.child_comment;
//    if (![[list class] isSubclassOfClass:[NSArray class]]) {
//        list = @[];
//    }
//    // 先移除后创建
//    [_answerBox.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    if (list.count>0) {
//        _answerBox.hidden = NO;
//        float x = 5;
//        float y = 5;
//        float w = kFMInteractionContentWidth;
//        float h = 0;
//        NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
//        
//        for (FMReviewModel *m in list) {
//            // 名字和内容列表
//            NSMutableAttributedString *attr = [FMReviewCell createAttrStringWithUname:m.nickName content:m.content];
//            // 拿到每行回复的大小
//            CGRect frame = [attr boundingRectWithSize:CGSizeMake(kFMInteractionContentWidth, CGFLOAT_MAX) options:options context:nil];
//            h = frame.size.height;
//            // 回复列表
//            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
//            l.attributedText = attr;
//            [_answerBox addSubview:l];
//            l = nil;
//            y += h;
//        }
//        _answerBox.frame = CGRectMake(_ask_time.frame.origin.x, _ask_time.frame.size.height+_ask_time.frame.origin.y+10, kFMInteractionContentWidth, y+5);
//    }else{
//        _answerBox.hidden = YES;
//    }

    
    NSString *userFace = model.userFace;
    NSURL *src;
    if (userFace) {
        
        if ([userFace hasPrefix:@"http"]) {
            src = [NSURL URLWithString:userFace];
        }else{
            src = [NSURL URLWithString:kURL(userFace)];
        }
    }
    
    if (src) {
        [_user_face sd_setImageWithURL:src placeholderImage:ThemeImage(@"me/me_icon_userface_normal")];
    }
    
    BOOL isLike = [_model.isLike boolValue];
    [self setLikeButtonStyle:isLike count:_model.likeCount];
}

-(void)clickLikeButtonAction{

    NSString *objcetId = _model.objectId;
    if (!objcetId || ![[objcetId class] isSubclassOfClass:[NSString class]]) {
        return;
    }
    _like.enabled = NO;
//    objcetId = [NSString stringWithFormat:@"fm_posts@%@",_model.postId];
    WEAKSELF
    [http setCommunityLikeWithObjectId:objcetId Start:^{
        
    } failure:^{
        __weakSelf.like.enabled = YES;
    } success:^(NSDictionary *dic){
        __weakSelf.like.enabled = YES;
        dic = [fn checkNullWithDictionary:dic];
        BOOL success = [dic[@"success"] boolValue];
        if (success) {
            // 返回总数
            dic = dic[@"data"];
            NSString* count = dic[@"count"];
            BOOL isLike = [dic[@"isLike"] boolValue];
            [__weakSelf setLikeButtonStyle:isLike count:count];
            
        }else{
            // 点赞失败
            NSLog(@"%@",dic);
        }
        
    }];
}

-(void)clicAskButtonAction{
    
}

#pragma mark - UI Change
-(void)setLikeButtonStyle:(BOOL)isLike count:(NSString*)count{
    if ([count intValue]<=0) {
        count = @"";
    }
    count = [count concate:@" "];
    [self.like setTitle:count forState:UIControlStateNormal];
    [self.like setTitle:count forState:UIControlStateHighlighted];
    if (!isLike) {
//        [self.like setTitleColor:FMBlackColor forState:UIControlStateNormal];
//        [self.like setImage:[UIImage imageWithTintColor:FMBottomLineColor blendMode:kCGBlendModeDestinationIn WithImageObject:ThemeImage(@"global/icon_like_normal")] forState:UIControlStateNormal];
//        [self.like setImage:[UIImage imageWithTintColor:FMBlueColor blendMode:kCGBlendModeDestinationIn WithImageObject:ThemeImage(@"global/icon_like_normal")] forState:UIControlStateHighlighted];
    }else{
//        [self.like setTitleColor:FMRedColor forState:UIControlStateNormal];
//        [self.like setImage:[UIImage imageWithTintColor:FMBottomLineColor blendMode:kCGBlendModeDestinationIn WithImageObject:ThemeImage(@"global/icon_like_normal")] forState:UIControlStateHighlighted];
//        [self.like setImage:[UIImage imageWithTintColor:FMRedColor blendMode:kCGBlendModeDestinationIn WithImageObject:ThemeImage(@"global/icon_like_normal")] forState:UIControlStateNormal];
    }
    
    _model.isLike = @(isLike).stringValue;
    _model.likeCount = count;
}

/**
 *  创建回复内容属性字符串
 *
 *  @param uname   用户名
 *  @param content 回复内容
 *
 *  @return 属性字符串
 */
+(NSMutableAttributedString*)createAttrStringWithUname:(NSString*)uname content:(NSString*)content{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:%@",uname,content]];
    // 字体
    [attr addAttribute:NSFontAttributeName value:kFont(14) range:NSMakeRange(0, attr.length)];
    // 颜色
    [attr addAttribute:NSForegroundColorAttributeName value:FMBlackColor range:NSMakeRange(0, attr.length)];
    // 用户名蓝色
    [attr addAttribute:NSForegroundColorAttributeName value:FMBlueColor range:NSMakeRange(0, uname.length+1)];
    
    return attr;
}




+(float)heightWithModel:(FMReviewModel*)model{
    float w = kFMInteractionContentWidth;
    float h = 0;
    NSString *content = model.content;
    
    if ([model.replyUserId intValue]>0) {
        NSString *replyStr = [NSString stringWithFormat:@"回复@%@:",model.replyNickName];
        // 回复样式
        content = [replyStr stringByAppendingString:content];
    }
    // 内容高度
    M80AttributedLabel *l = [[M80AttributedLabel alloc] initWithFrame:CGRectMake(0, 0, w, CGFLOAT_MAX)];
    // 文本行间隙
    l.lineSpacing = kFMInteractionContentLineSpace;
    l.font = kDefaultFont;
    l.text = content;
    [l sizeToFit];
    h = l.frame.size.height+kFMInteractionFaceWidth+kFMInteractionPadding;
    
//    // 回复高度
//    NSArray *list = model.child_comment;
//    if (![[list class] isSubclassOfClass:[NSArray class]]) {
//        list = @[];
//    }
//    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    float rh = 0;
//    if (list.count>0) {
//        for (FMReviewModel *m in list) {
//            // 名字和内容列表
//            NSMutableAttributedString *attr = [self createAttrStringWithUname:m.nickName content:m.content];
//            // 拿到每行回复的大小
//            CGRect frame = [attr boundingRectWithSize:CGSizeMake(kFMInteractionContentWidth, CGFLOAT_MAX) options:options context:nil];
//            rh += frame.size.height;
//        }
//    }
//    list = nil;
    
    h += rh+kFMInteractionPadding;
    l = nil;
    return h;
}

/**
 *  这个是TYAttributedLabel的代理方法
 *
 *  @param attributedLabel 点击对象
 *  @param textStorage     代理对象
 *  @param point           点击方位
 */

-(void)m80AttributedLabel:(M80AttributedLabel *)label clickedOnLink:(id)linkData{

}

@end
