//
//  FMShowPhotoViewController.h
//  FMMarket
//
//  Created by dangfm on 16/5/4.
//  Copyright © 2016年 dangfm. All rights reserved.
//

#import "FMBaseViewController.h"

#define kFMShowPhotoComplateCloseNotificationKey @"kFMShowPhotoViewControllerComplateCloseNotificationKey"
typedef enum {
    direction_Horizontal,    // 横屏
    direction_Vertical       // 竖屏
} DirectionStyle;
@class FMShowPhotoViewController;
typedef void (^moveBlock)(int page);

@interface FMShowPhotoViewController : FMBaseViewController

@property (nonatomic,copy) moveBlock moveBlock;

+(instancetype)sharedManager;
-(instancetype)initWithPhotos:(NSArray*)images;
-(void)createPhotos:(NSArray*)images Index:(NSInteger)index ScreenType:(DirectionStyle)screenType BackgroundImg:(UIImage*)backgroundImg;


@end
