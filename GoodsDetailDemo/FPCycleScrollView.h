//
//  FPCycleScrollView.h
//  WholeSale
//
//  Created by fanpeng on 2017/8/15.
//  Copyright © 2017年 ZhaiJia. All rights reserved.
//

#import <SDCycleScrollView/SDCycleScrollView.h>

@interface FPCycleScrollView : SDCycleScrollView

@property (nonatomic, assign) CGFloat pageNumberLabelOffset;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL showPageNumberLabel;

- (void)scrollToItemAtIndex:(NSInteger)index;

 @end
