//
//  FMNavBarTool.m
//  golden_ipad
//
//  Created by dangfm on 16/8/24.
//  Copyright © 2016年 dangfm. All rights reserved.
//

#import "FMNavBarTool.h"

@interface FMNavBarTool(){

}
@property (nonatomic,retain) UIScrollView *scrollView;  // 滚动view
@property (nonatomic,retain) UIView *main;        // 盒子
@property (nonatomic,retain) NSArray *titles;           // 按钮标题
@property (nonatomic,retain) UIButton *selectButton;    // 当前点击的按钮

@end

@implementation FMNavBarTool

-(void)dealloc{
    NSLog(@"FMNavBarTool dealloc");
}

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray*)titles{
    return [self initWithFrame:frame titles:titles bottomLineStyle:FMNavBarToolBottomLineStyle_None];
}

// 带底部线条样式的初始化方式
-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles bottomLineStyle:(FMNavBarToolBottomLineStyle)bottomLineStyle{
    return [self initWithFrame:frame titles:titles bottomLineStyle:bottomLineStyle isScrolling:NO];
}

// 带底部线条样式的初始化方式 是否滚动
-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles bottomLineStyle:(FMNavBarToolBottomLineStyle)bottomLineStyle isScrolling:(BOOL)isScrolling{
    if (self==[super initWithFrame:frame]) {
        _titles = titles;
        _bottomLineStyle = bottomLineStyle;
        _isScrolling = isScrolling;
        [self createViews];
    }
    return self;
}

-(void)layoutSubviews{
    [self updateButtons];
    [self moveBottomLineWithSelectButton:_selectButton];
    WEAKSELF
    [fn sleepSeconds:0.6 finishBlock:^{
        [__weakSelf moveBottomLineWithSelectButton:_selectButton];
    }];
}

//-(void)layoutIfNeeded{
//    [self moveBottomLineWithSelectButton:_selectButton];
//}

// 生成视图
-(void)createViews{
    self.backgroundColor = kFMNavBarTool_BgColor;
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.scrollEnabled = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
    }
    if (!_main) {
        _main = [[UIView alloc] initWithFrame:self.bounds];
//        _main.backgroundColor = [UIColor blackColor];
        [_scrollView addSubview:_main];
    }
    
    // 生成按钮
    [self createButtons];
}

// 生成所有按钮
-(void)createButtons{
    int count = (int)_titles.count;
    float x = 0;
    float y = 0;
    float w = self.frame.size.width / count;
    float h = self.frame.size.height;
    float paddingLeft = 0;
    // 滚动处理
    if (_isScrolling) {
        paddingLeft = kFMNavBarTool_MarginLeft;
    }
    x = paddingLeft;
    
    for (int i=0; i<count; i++) {
        UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
        NSString *title = _titles[i];
        if (_isScrolling) {
            w = [title sizeWithAttributes:@{NSFontAttributeName:kFMNavBarTool_Font}].width;
            bt.frame = CGRectMake(x, y, w , h);
        }
        bt.tag = i;
        [bt setTitle:title forState:UIControlStateNormal];
        [bt setTitleColor:kFMNavBarTool_TextColor forState:UIControlStateNormal];
        bt.titleLabel.font = kFMNavBarTool_Font;
        bt.titleLabel.adjustsFontSizeToFitWidth = YES;
        [bt addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_main addSubview:bt];
        x += w;
        x += paddingLeft;
        if (i==0) {
            _selectButton = bt;
        }
        bt = nil;
    }
    
    // 如滚动的话需要设置scrollview的内容宽度
    _scrollView.scrollEnabled = _scrollView;
    if (_isScrolling) {
        // 设置内容的宽度可以滚动
        if (x<_scrollView.frame.size.width) {
            x = _scrollView.frame.size.width;
        }
        _scrollView.contentSize = CGSizeMake(x, h);
    }else{
//        [_main makeSubViewsEqualWidthLRpadding:0 viewPadding:0];
    }
    
    // 底部线条
    [self createBottomLine];
}

// 更新button的位置
-(void)updateButtons{
    _scrollView.frame = self.bounds;
    _main.frame = self.bounds;
    if (!_isScrolling) {
        return;
    }
    int count = (int)_titles.count;
    float x = 0;
    float y = 0;
    float w = self.frame.size.width / count;
    float h = self.frame.size.height;
    float paddingLeft = 0;
    // 如果是滚动的菜单，默认设置每行显示6个
    // 菜单需要滚动的话，设置每个按钮间的距离为20，长度就等于字数的宽度
    paddingLeft = kFMNavBarTool_MarginLeft;
    x = paddingLeft;
    // 模拟一次排列
    for (int i=0; i<count; i++) {
        UIButton *bt = _main.subviews[i];
        NSString *title = _titles[i];
        w = [title sizeWithAttributes:@{NSFontAttributeName:kFMNavBarTool_Font}].width;
        bt.frame = CGRectMake(x, y, w , h);
        x += w;
        x += paddingLeft;
        bt = nil;
    }
    
    // 如果发现排练后还剩好多空间，那么重新排列
    if (x<_scrollView.frame.size.width) {
        float space = _scrollView.frame.size.width - x;
        paddingLeft += space / count;
        x = paddingLeft;
        // 重新排列
        for (int i=0; i<count; i++) {
            UIButton *bt = _main.subviews[i];
            NSString *title = _titles[i];
            w = [title sizeWithAttributes:@{NSFontAttributeName:kFMNavBarTool_Font}].width;
            bt.frame = CGRectMake(x, y, w , h);
            x += w;
            x += paddingLeft;
            bt = nil;
        }
    }
    // 如果超出了宽度并且不需要滚动，那就重新排列满
    if (x>_scrollView.frame.size.width && !_isScrolling) {
        float space = _scrollView.frame.size.width - x;
        paddingLeft += space / count;
        x = paddingLeft;
        // 重新排列
        for (int i=0; i<count; i++) {
            UIButton *bt = _main.subviews[i];
            NSString *title = _titles[i];
            w = [title sizeWithAttributes:@{NSFontAttributeName:kFMNavBarTool_Font}].width;
            bt.frame = CGRectMake(x, y, w , h);
            x += w;
            x += paddingLeft;
            bt = nil;
        }
    }
    
    // 如滚动的话需要设置scrollview的内容宽度
    if (_isScrolling) {
        // 设置内容的宽度可以滚动
        if (x<_scrollView.frame.size.width) {
            x = _scrollView.frame.size.width;
        }
        _scrollView.contentSize = CGSizeMake(x, h);
        _main.frame = CGRectMake(0, 0,  _scrollView.contentSize.width,  _scrollView.contentSize.height);
    }
}

// 生成底部线条
-(void)createBottomLine{
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-kFMNavBarTool_LineHeight, 0, kFMNavBarTool_LineHeight)];
    _line.backgroundColor = FMBlackColor;
    _line.contentMode = UIViewContentModeScaleAspectFill;
    [_scrollView addSubview:_line];
    if (_bottomLineStyle==FMNavBarToolBottomLineStyle_None) {
        _line.hidden = YES;
    }
    if (_bottomLineStyle==FMNavBarToolBottomLineStyle_Line) {
        _line.hidden = NO;
    }
    if (_bottomLineStyle==FMNavBarToolBottomLineStyle_Triangle) {
        _line.hidden = NO;
        _line.frame = CGRectMake(0, self.frame.size.height-kFMNavBarTool_TriangleHeight+6, kFMNavBarTool_TriangleWidth, kFMNavBarTool_TriangleHeight);
        UIImage *triangle = ThemeImage(@"global/icon_triangle_normal");
//        triangle = [UIImage imageByScalingAndCroppingForSourceImage:triangle targetSize:_line.size];
        triangle = [UIImage imageWithTintColor:[UIColor whiteColor] blendMode:kCGBlendModeDestinationIn WithImageObject:triangle];
        _line.image = triangle;
        _line.backgroundColor = [UIColor clearColor];
    }
    
}

// 底部线条跟着移动
-(void)moveBottomLineWithSelectButton:(UIButton*)sender{
    if (_bottomLineStyle==FMNavBarToolBottomLineStyle_None) {
        return;
    }
    
    // 按钮字体恢复原样
    for (UIButton *bt in _main.subviews) {
        bt.titleLabel.font = kFMNavBarTool_Font;
    }
    
    sender.titleLabel.font = kFMNavBarTool_FontBold;
    
    float x = sender.frame.origin.x;
    float h = _line.frame.size.height;
    float y = sender.frame.size.height - h;
    float w = sender.frame.size.width;
    
    if (_bottomLineStyle==FMNavBarToolBottomLineStyle_Line) {
        // 线条移动
        float tw = [sender.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:sender.titleLabel.font}].width;
        x += (w - tw) / 2;
        w = tw;
        WEAKSELF
        [UIView animateWithDuration:kFMNavBarTool_MoveTime animations:^{
            __weakSelf.line.frame = CGRectMake(x, y, w , h);
        } completion:^(BOOL finished){
            
        }];
        
    }
    if (_bottomLineStyle==FMNavBarToolBottomLineStyle_Triangle) {
        // 三角形移动
        y += 6;
        float tw = _line.frame.size.width;
        x += (w - tw) / 2.0;
        w = tw;
        WEAKSELF
        [UIView animateWithDuration:kFMNavBarTool_MoveTime animations:^{
            __weakSelf.line.frame = CGRectMake(x, y, w , h);
        } completion:^(BOOL finished){
            
        }];
    }
    
    if (_isScrolling) {
        // 偏移到指定位置 让下一个按钮显示出来
        // 下一个按钮的宽度
        int nextTag = (int)sender.tag + 1;
        int preTag = (int)sender.tag - 1;
        x = sender.frame.origin.x;
        w = sender.frame.size.width;
        x += w + 2*kFMNavBarTool_MarginLeft;
        w = _scrollView.frame.size.width;
        // 往后移动
        if (nextTag<_main.subviews.count) {
            UIButton *nextButton = _main.subviews[nextTag];
            float nextBtWidth = nextButton.frame.size.width;
            float sx = (float)_scrollView.contentOffset.x;
            if (fabsf(x - w - sx)<nextBtWidth || (sx+_scrollView.frame.size.width)<(nextBtWidth+nextButton.frame.origin.x)) {
                // 移动到下一个
                float scrollX = nextBtWidth*2 + sx;
                if (scrollX>=_scrollView.contentSize.width-_scrollView.frame.size.width) {
                    scrollX = _scrollView.contentSize.width-_scrollView.frame.size.width;
                }
                [_scrollView setContentOffset:CGPointMake(scrollX, 0) animated:YES];
            }
            if (nextTag==_main.subviews.count-1) {
                float scrollX = _scrollView.contentSize.width-_scrollView.frame.size.width;
                [_scrollView setContentOffset:CGPointMake(scrollX, 0) animated:YES];
            }
        }
        if (preTag<=0) {
            preTag = 0;
        }
        // 往前移动
        if (preTag>=0 && preTag<_main.subviews.count) {
            UIButton *preButton = _main.subviews[preTag];
            float preBtWidth = preButton.frame.size.width;
            float preBtX = preButton.frame.origin.x;
            float sx = (float)_scrollView.contentOffset.x;
            if (preBtX<sx) {
                // 移动到上一个
                float scrollX = preBtX-2*preBtWidth;
                if (scrollX<=0) {
                    scrollX = 0;
                }
                [_scrollView setContentOffset:CGPointMake(scrollX, 0) animated:YES];
            }
            if (preTag==0) {
                [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
        }
    }
    
    
}

// 底部线条移动到某个按钮下
-(void)moveBottomLineToSelectButtonWithTag:(NSInteger)tag{
    if (_bottomLineStyle==FMNavBarToolBottomLineStyle_None) {
        return;
    }
    if (tag<_main.subviews.count) {
        UIButton *bt = _main.subviews[tag];
        [self moveBottomLineWithSelectButton:bt];
        _selectTag = tag;
    }
}

// 设置字体颜色
-(void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    for (UIButton *bt in _main.subviews) {
        [bt setTitleColor:_textColor forState:UIControlStateNormal];
    }
}

// 设置字体
-(void)setFont:(UIFont *)font{
    _font = font;
    for (UIButton *bt in _main.subviews) {
        bt.titleLabel.font = _font;
    }

}

// 点击按钮 传送回调
-(void)clickButtonAction:(UIButton*)sender{
    _selectButton = sender;
    // 点击按钮，底部线条跟着移动
    [self moveBottomLineWithSelectButton:sender];
    
    if (self.clickNavBarToolAction) {
        self.clickNavBarToolAction(sender.tag);
    }
}

@end
