//
//  FMTableViewCell.m
//  FMMarket
//
//  Created by dangfm on 15/8/8.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMTableViewCell.h"
#import "UILabel+stocking.h"
#import "UIButton+stocking.h"

@implementation FMTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self==[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createViews];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    _line.frame = CGRectMake(kTableViewCellLeftPadding,
                             self.bounds.size.height-kTableViewCellLineHeight,
                             UIScreenWidth,
                             kTableViewCellLineHeight);
    
    _changeRate.frame = CGRectMake(UIScreenWidth-kTableViewCellLeftPadding-kTableViewCellButtonWidth,
                                   (self.bounds.size.height-kTableViewCellButtonHeight)/2,
                                   kTableViewCellButtonWidth,
                                   kTableViewCellButtonHeight);
    
    _arrow.frame = CGRectMake(UIScreenWidth-kTableViewCellLeftPadding-_arrow.frame.size.width,
                              (self.bounds.size.height-_arrow.frame.size.height)/2,
                              _arrow.frame.size.width,
                              _arrow.frame.size.height);
    
    if (self.imageView.image) {
        CGFloat w = self.leftImageWidth;
        if (w<=0) w = 50;
        if (w<self.imageView.frame.size.width) {
            w=self.imageView.frame.size.width;
        }
        CGRect f = self.imageView.frame;
        [self.imageView setFrame:CGRectMake(5+(w-f.size.width)/2, f.origin.y,f.size.width, f.size.height)];
        if (_isCorner) {
            self.imageView.layer.cornerRadius = f.size.width/2;
            self.imageView.layer.masksToBounds = YES;
            self.imageView.layer.borderColor = FMBottomLineColor.CGColor;
            self.imageView.layer.borderWidth = 0.5;
        }
        _title.frame = CGRectMake(w+10,0,UIScreenWidth-w-10,self.bounds.size.height);
        _line.frame = CGRectMake(w+10,
                                 self.bounds.size.height-kTableViewCellLineHeight,
                                 UIScreenWidth-w-10,
                                 kTableViewCellLineHeight);
    }else{
        if (self.leftImageWidth>0) {
            _title.frame = CGRectMake(self.leftImageWidth,0,
                                      UIScreenWidth-self.leftImageWidth,
                                      self.bounds.size.height);
            _line.frame = CGRectMake(self.leftImageWidth,
                                     self.bounds.size.height-kTableViewCellLineHeight,
                                     UIScreenWidth-self.leftImageWidth,
                                     kTableViewCellLineHeight);
        }
        
    }
    
    if (_leftImageView.image) {
        CGFloat w = self.leftImageWidth;
        if (w<=0) w = 50;
        
        CGRect f = _leftImageView.frame;
        if (_isAutoReSizeImage) {
            float h = _leftImageView.image.size.height;
            float ww = _leftImageView.image.size.width;
            float bl = h / ww;
            if (ww>w) {
                ww = w - 20;
                h = bl * ww;
            }
            [_leftImageView setFrame:CGRectMake((self.leftImageWidth-ww)/2, (self.frame.size.height-h)/2,ww, h)];
        }else{
            [_leftImageView setFrame:CGRectMake(_leftImageView.frame.origin.x, (self.frame.size.height-w)/2,w, w)];
            w +=20;
        }
        
        f = _leftImageView.frame;
        if (_isCorner) {
            _leftImageView.layer.cornerRadius = f.size.width/2;
            _leftImageView.layer.masksToBounds = YES;
            _leftImageView.layer.borderColor = FMBottomLineColor.CGColor;
            _leftImageView.layer.borderWidth = 0.5;
        }
        _title.frame = CGRectMake(w,0,UIScreenWidth-w-kTableViewCellLeftPadding,self.bounds.size.height);
        _line.frame = CGRectMake(w,
                                 self.bounds.size.height-kTableViewCellLineHeight,
                                 UIScreenWidth-w,
                                 kTableViewCellLineHeight);
    }
    
    if (_isLast) {
        _line.frame = CGRectMake(0,
                                 self.bounds.size.height-kTableViewCellLineHeight,
                                 UIScreenWidth,
                                 kTableViewCellLineHeight);
    }
    if (![_intro.text isEqualToString:@""]) {
        _intro.hidden = NO;
        [_intro sizeToFit];
        float y = self.bounds.size.height/2-_title.font.lineHeight-2;
        
        if (_intro.frame.size.height>(_intro.font.lineHeight*1.5)) {
            // 多行
            y = kTableViewCellLeftPadding;
        }
        [_title sizeToFit];
        _title.frame = CGRectMake(_title.frame.origin.x,
                                  y,
                                  UIScreenWidth-_title.frame.origin.x-kTableViewCellLeftPadding,
                                  _title.frame.size.height);
        _intro.frame = CGRectMake(_title.frame.origin.x, _title.font.lineHeight+_title.frame.origin.y+3, _title.frame.size.width, _intro.frame.size.height);
    }
    
    self.unReadLb.font = kFontNumber(12);
    [self.unReadLb sizeToFit];
    
    float y = 5;
    float w = self.unReadLb.frame.size.width+5;
    if (w<18) {
        w = 18;
    }
    float h = 18;
    float x = self.leftImageWidth - w / 2;
    
    self.unReadLb.frame = CGRectMake(x, y, w, h);
    self.unReadLb.backgroundColor = [UIColor redColor];
    self.unReadLb.textColor = [UIColor whiteColor];
    self.unReadLb.textAlignment = NSTextAlignmentCenter;
    self.unReadLb.layer.masksToBounds = YES;
    self.unReadLb.layer.cornerRadius = self.unReadLb.frame.size.height/2;
    
}

-(void)createViews{
    
    UIView *selectView = [[UIView alloc] initWithFrame:self.frame];
    selectView.backgroundColor = ThemeColor(@"UITableViewCell_SelectView_BackgroundColor");
    self.selectedBackgroundView = selectView;
    
    _title = [UILabel createWithTitle:@"" Frame:self.bounds];
    _title.font = kFont(kTableViewCellTitleFontSize);
    _typeIcon = [UILabel createWithTitle:@"" Frame:self.bounds];
    _typeIcon.font = kFontNumber(kTableViewCellCodeFontSize);
    _code = [UILabel createWithTitle:@"" Frame:self.bounds];
    _code.font = kFontNumber(kTableViewCellCodeFontSize);
    _price = [UILabel createWithTitle:@"" Frame:self.bounds];
    _price.font = kFontNumber(kTableViewCellPriceFontSize);
    _changeRate = [UIButton createWithTitle:@""
                                      Frame:CGRectMake(UIScreenWidth-kTableViewCellLeftPadding-kTableViewCellButtonWidth, (self.bounds.size.height-kTableViewCellButtonHeight)/2, kTableViewCellButtonWidth, kTableViewCellButtonHeight)];
    _changeRate.titleLabel.font = kFontNumberBold(kTableViewCellChangeRateFontSize);
    [_changeRate setBackgroundImage:[UIImage imageWithColor:FMGreyColor andSize:_changeRate.frame.size]
                           forState:UIControlStateNormal];
    _changeRate.layer.masksToBounds = YES;
    _changeRate.layer.cornerRadius = kTableViewCellButtonCorner;
    _line = [[UIView alloc] initWithFrame:CGRectMake(kTableViewCellLeftPadding,
                                                    self.bounds.size.height-kTableViewCellLineHeight,
                                                    UIScreenWidth,
                                                    kTableViewCellLineHeight)];
    _line.backgroundColor = ThemeColor(@"UITableViewCell_BottomLine_Color");
    _arrow = [[UIImageView alloc] initWithImage:ThemeImage(@"global/tableviewcell_icon_in")];
    _intro = [UILabel createWithTitle:@"" Frame:self.bounds];
    _signal = [UILabel createWithTitle:@"B" Frame:CGRectMake(_title.frame.size.width+_title.frame.origin.x, _title.frame.origin.y, _title.font.pointSize, _title.font.pointSize)];
    _signal.font = kFontNumber(12);
    _signal.layer.cornerRadius = _signal.frame.size.width/2;
    _signal.textAlignment = NSTextAlignmentCenter;
    _signal.layer.masksToBounds = YES;
    _signal.textColor = [UIColor whiteColor];
    
    _leftImageView = [[UIImageView alloc] init];
    _leftImageView.contentMode = UIViewContentModeScaleToFill;
    _unReadLb = [[UILabel alloc] init];
    
    [self.contentView addSubview:_title];
    [self.contentView addSubview:_code];
    [self.contentView addSubview:_typeIcon];
    [self.contentView addSubview:_price];
    [self.contentView addSubview:_changeRate];
    [self.contentView addSubview:_line];
    [self.contentView addSubview:_arrow];
    [self.contentView addSubview:_intro];
    [self.contentView addSubview:_signal];
    [self.contentView addSubview:_leftImageView];
    [self.contentView addSubview:_unReadLb];
    
    _code.hidden = YES;
    _price.hidden = YES;
    _changeRate.hidden = YES;
    _arrow.hidden = YES;
    _intro.hidden = YES;
    _signal.hidden = YES;
    _unReadLb.hidden = YES;
    self.backgroundColor = [UIColor whiteColor];
}

@end
