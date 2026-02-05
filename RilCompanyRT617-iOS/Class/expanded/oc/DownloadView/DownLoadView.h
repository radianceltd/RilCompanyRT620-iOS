//
//  DownLoadView.h
//  BWProject
//
//  Created by rnd on 2018/7/4.
//  Copyright © 2018年 Radiance Instruments Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DownLoadView;

@protocol DownLoadViewDelegate <NSObject>;

-(void)ClickToStartTheDownLoadBtnInLoadView:(DownLoadView *)downLoadView ;

@end;

@interface DownLoadView : UIView

/** MusicalProgress */
@property (nonatomic, assign) CGFloat musicalProgress;

/** placeholderText */
@property (nonatomic, copy) NSString *placeholderText;

/** placeholderBtnText */
@property (nonatomic, copy) NSString *placeholderBtnText;

/** placeholderFont */
@property (nonatomic) UIFont *placeholderFont;

/** placeholderBtnFont */
@property (nonatomic) UIFont *placeholderBtnFont;

/** MusicalColor */
@property (nonatomic) UIColor *musicalColor;

/** TitleColor */
@property (nonatomic) UIColor *titleColor;

/** ZWMusicDownLoadLab */
@property (nonatomic, strong) UILabel *musicDownLoadLab;

//当前的下载大小
@property(nonatomic,strong) UILabel *currentLoadLb;

//总的下载大小
@property(nonatomic,strong) UILabel *totalLoadLb;


/** ZWMusicDownLoadViewDelegate */
@property (nonatomic, weak) id<DownLoadViewDelegate>  delegate;

- (void)startDownLoad;
- (void)endDownLoad;

@end
