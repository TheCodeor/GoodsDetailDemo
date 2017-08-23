//
//  CustomNavView.m
//  GoodsDetailDemo
//
//  Created by fanpeng on 2017/8/22.
//  Copyright © 2017年 fanpeng. All rights reserved.
//

#import "CustomNavView.h"
#import "UIColor+Hex.h"
#import "SDAutoLayout.h"

@interface CustomNavView ()

@property (nonatomic, weak) IBOutlet UIButton *goodsButton;
@property (nonatomic, weak) IBOutlet UIButton *detailButton;
@property (nonatomic, weak) IBOutlet UILabel  *titleLabel;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation CustomNavView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.goodsButton.selected = YES;
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor colorWithHexString:@"#FA8545"];
    [self addSubview:self.lineView];
    [self layoutLineViewWithButton:self.goodsButton animation:NO];
}

- (IBAction)backButtonClick:(id)sender {
    
}

- (IBAction)goodsButtonClick:(id)sender {
    
    [self selectGoodsButton];
    if ([self.customNavViewDelegate respondsToSelector:@selector(clickGoodsButton:)]) {
        [self.customNavViewDelegate clickGoodsButton:self.goodsButton];
    }
}

- (IBAction)detailButtonClick:(id)sender {
    [self selectDetailButton];
    if ([self.customNavViewDelegate respondsToSelector:@selector(clickDetailButton:)]) {
        [self.customNavViewDelegate clickDetailButton:self.detailButton];
    }
}

- (void)selectGoodsButton {
    self.goodsButton.selected = YES;
    self.detailButton.selected = NO;
    [self layoutLineViewWithButton:self.goodsButton animation:YES];
}

- (void)selectDetailButton {
    self.goodsButton.selected = NO;
    self.detailButton.selected = YES;
    [self layoutLineViewWithButton:self.detailButton animation:YES];
}

- (void)layoutLineViewWithButton:(UIButton *)button animation:(BOOL)animation {
    
    self.lineView.sd_layout
    .centerXEqualToView(button)
    .bottomEqualToView(self)
    .heightIs(2)
    .widthIs(31);
    
    if (animation) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.lineView updateLayout];
        }];
    }
}

@end
