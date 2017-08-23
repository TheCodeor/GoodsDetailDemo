//
//  CustomNavView.h
//  GoodsDetailDemo
//
//  Created by fanpeng on 2017/8/22.
//  Copyright © 2017年 fanpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomNavViewDelegate <NSObject>

- (void)clickGoodsButton:(UIButton *)button;
- (void)clickDetailButton:(UIButton *)button;

@end

@interface CustomNavView : UIView

@property (nonatomic, weak) id <CustomNavViewDelegate> customNavViewDelegate;

- (void)selectGoodsButton;
- (void)selectDetailButton;

@end
