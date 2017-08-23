//
//  FPCycleScrollView.m
//  WholeSale
//
//  Created by fanpeng on 2017/8/15.
//  Copyright © 2017年 ZhaiJia. All rights reserved.
//

#import "FPCycleScrollView.h"

@interface FPCycleScrollView ()

@property (nonatomic, strong) UILabel *pageNumberLabel;

@end

@implementation FPCycleScrollView


- (UILabel *)pageNumberLabel {
    if (!_pageNumberLabel) {
        _pageNumberLabel = [[UILabel alloc] init];
        _pageNumberLabel.backgroundColor = [UIColor whiteColor];
        _pageNumberLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        _pageNumberLabel.font = [UIFont systemFontOfSize:12];
        _pageNumberLabel.textAlignment = NSTextAlignmentCenter;
        _pageNumberLabel.clipsToBounds = YES;
        _pageNumberLabel.layer.cornerRadius = 9.0f;
        [self addSubview:_pageNumberLabel];
    }
    return _pageNumberLabel;
}

- (void)setShowPageNumberLabel:(BOOL)showPageNumberLabel {
    _showPageNumberLabel = showPageNumberLabel;
    self.pageNumberLabel.hidden = !showPageNumberLabel;
    self.pageNumberLabelOffset = 0;
}

- (void)setPageNumberLabelOffset:(CGFloat)pageNumberLabelOffset {
    _pageNumberLabelOffset = pageNumberLabelOffset;
    self.pageNumberLabel.sd_layout
    .bottomSpaceToView(self, 11 + pageNumberLabelOffset)
    .rightSpaceToView(self, 23)
    .widthIs(36)
    .heightIs(18);
    [self.pageNumberLabel updateLayout];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    self.pageNumberLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)currentPage,(long)self.imageURLStringsGroup.count];
}


- (void)scrollToItemAtIndex:(NSInteger)index {

    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UICollectionView class]]) {
            UICollectionView *collectionView = (UICollectionView *)view;
            [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                                   atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }
}


@end
